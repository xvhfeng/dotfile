#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <ev.h>

#include "spx_socket.h"
#include "spx_alloc.h"
#include "spx_string.h"
#include "spx_message.h"
#include "spx_path.h"
#include "spx_nio.h"
#include "spx_io.h"
#include "spx_list.h"
#include "spx_defs.h"
#include "spx_job.h"
#include "spx_time.h"

#include "ydb_protocol.h"
#include "ydb_storage_configurtion.h"
#include "ydb_storage_runtime.h"
#include "ydb_storage_sync_heartbeat.h"

struct spx_map *g_ydb_remote_storages = NULL;

spx_private ev_timer *sync_heartbet_timer = NULL;
spx_private struct ev_loop *sync_heart_loop = NULL;


spx_private void ydb_storage_sync_heartbeat_nio_writer(struct spx_job_context *jc);
spx_private void ydb_storage_sync_heartbeat_nio_reader(struct spx_job_context *jc);
spx_private err_t ydb_storage_sync_heartbeat_query_remote_storage(struct ev_loop *loop,
        struct ydb_tracker *tracker,u32_t timeout);
spx_private void *ydb_storage_sync_heartbeat_regedit_timer(void *arg);
spx_private void ydb_storage_sync_heartbeat_query_storages(struct ev_loop *loop,\
        ev_timer *w,int revents);
spx_private err_t ydb_storage_sync_heartbeat_query_storages_once(
        struct ydb_storage_configurtion *c);

spx_private err_t ydb_storage_sync_heartbeat_query_remote_storage(struct ev_loop *loop,
        struct ydb_tracker *tracker,u32_t timeout){/*{{{*/
    err_t err = 0;
    struct spx_job_context *jc = tracker->sync_heartbeat_jc;
    jc->data = tracker;
    struct ydb_storage_configurtion *c = (struct ydb_storage_configurtion *) jc->config;

    int fd = spx_socket_new(&err);
    if(0 >= fd){
        SpxLogFmt2(jc->log,SpxLogError,err,
                "create heartbeat socket fd is fail."
                "tracker ip:%s port:%d.",
                tracker->host.ip,tracker->host.port);
        return err;
    }
        SpxLogFmt1(jc->log,SpxLogInfo,
                "open  fd:%d for heartbeat.",
                fd);

    jc->fd = fd;
    if(0 != (err = spx_set_nb(fd))){
        SpxLogFmt2(jc->log,SpxLogError,err,
                "set socket fd nonblacking is fail."
                "tracker ip:%s port:%d.",
                tracker->host.ip,tracker->host.port);
        goto r1;
    }
    if(0 != (err = spx_socket_set(fd,SpxKeepAlive,SpxAliveTimeout,\
                    SpxDetectTimes,SpxDetectTimeout,\
                    SpxLinger,SpxLingerTimeout,\
                    SpxNodelay,\
                    true,timeout))){
        SpxLogFmt2(jc->log,SpxLogError,err,
                "set socket fd is fail."
                "tracker ip:%s port:%d.",
                tracker->host.ip,tracker->host.port);
        goto r1;
    }
    if(0 != (err = spx_socket_connect_nb(fd,tracker->host.ip,tracker->host.port,timeout))){
        SpxLogFmt2(jc->log,SpxLogError,err,\
                "conntect to tracker:%s:%d is fail.",\
                tracker->host.ip,tracker->host.port);
        goto r1;
    }

    struct spx_msg_header *writer_header = NULL;
    writer_header = spx_alloc_alone(sizeof(*writer_header),&err);
    if(NULL == writer_header){
        SpxLogFmt2(jc->log,SpxLogError,err,\
                "alloc writer header  send to tracker ip:%s port:%d is fail.",
                tracker->host.ip,tracker->host.port);
        goto r1;
    }
    jc->writer_header = writer_header;
    writer_header->version = YDB_VERSION;
    writer_header->protocol = YDB_S2T_QUERY_SYNC_STORAGES;
    writer_header->bodylen = YDB_GROUPNAME_LEN + YDB_MACHINEID_LEN
                             + YDB_SYNCGROUP_LEN ;
    writer_header->is_keepalive = c->iskeepalive;//persistent connection


    struct spx_msg *ctx = spx_msg_new(writer_header->bodylen,&err);
    if(NULL == ctx){
        SpxLogFmt2(jc->log,SpxLogError,err,\
                "alloc writer body send to tracker ip:%s port:%d is fail.",
                tracker->host.ip,tracker->host.port);
        goto r1;
    }
    jc->writer_body_ctx = ctx;
    spx_msg_pack_fixed_string(ctx,c->groupname,YDB_GROUPNAME_LEN);
    spx_msg_pack_fixed_string(ctx,c->machineid,YDB_MACHINEID_LEN);
    spx_msg_pack_fixed_string(ctx,c->syncgroup,YDB_SYNCGROUP_LEN);

    jc->lifecycle = SpxNioLifeCycleHeader;
    jc->nio_writer(EV_WRITE,jc);
    return err;
r1:
    spx_job_context_clear(jc);
    SpxClose(fd);
    return err;
}/*}}}*/

spx_private void ydb_storage_sync_heartbeat_query_storages(struct ev_loop *loop,\
        ev_timer *w,int revents){/*{{{*/
    struct ydb_storage_configurtion *c = (struct ydb_storage_configurtion *) \
                                         w->data;
    ydb_storage_sync_heartbeat_query_storages_once(c);
    return;
}/*}}}*/

spx_private err_t ydb_storage_sync_heartbeat_query_storages_once(
        struct ydb_storage_configurtion *c
        ) {/*{{{*/
    err_t err = 0;
    SpxLog1(c->log,SpxLogInfo,
            "query remote in the same syncgroup for sync.");
    struct spx_vector_iter *iter = spx_vector_iter_new(c->trackers ,&err);
    if(NULL == iter){
        SpxLog2(c->log,SpxLogError,err,\
                "init the trackers iter is fail.");
        return err;
    }

    struct ydb_tracker *t = NULL;
    while(NULL != (t = spx_vector_iter_next(iter))){
        err = ydb_storage_sync_heartbeat_query_remote_storage(
                sync_heart_loop,t,c->timeout);
    }
    spx_vector_iter_free(&iter);
    return err;
}/*}}}*/

spx_private void *ydb_storage_sync_heartbeat_regedit_timer(void *arg){/*{{{*/
    struct ydb_storage_configurtion *c = (struct ydb_storage_configurtion *) arg;
    if(NULL == c){
        return NULL;
    }
    ev_timer_init(sync_heartbet_timer,
            ydb_storage_sync_heartbeat_query_storages,
            (double) c->query_sync_timespan ,(double) c->query_sync_timespan);
    ev_timer_start(sync_heart_loop,sync_heartbet_timer);
    ev_run(sync_heart_loop,0);
    return NULL;
}/*}}}*/

spx_private void ydb_storage_sync_heartbeat_nio_writer(struct spx_job_context *jc){/*{{{*/
    struct ydb_storage_configurtion *c = (struct ydb_storage_configurtion *) jc->config;
    jc->lifecycle = SpxNioLifeCycleHeader;
    ev_once(jc->tc->loop,jc->fd,EV_READ,c->waitting,jc->nio_reader,(void *) jc);
}/*}}}*/

spx_private void ydb_storage_sync_heartbeat_nio_reader(struct spx_job_context *jc){/*{{{*/
    struct spx_msg *ctx = jc->reader_body_ctx;
    struct ydb_storage_configurtion *c = (struct ydb_storage_configurtion *) jc->config;
    struct ydb_tracker *t = (struct ydb_tracker *) jc->data;
    err_t err = 0;
    if(NULL == ctx){
        SpxLog2(jc->log,SpxLogError,jc->err,\
                "no recved the body ctx.");
        goto r1;
    }
    spx_msg_seek(ctx,0,SpxMsgSeekSet);
    u32_t count = spx_msg_size(ctx) /
        (YDB_MACHINEID_LEN  + SpxIpv4Size + sizeof(u32_t) + sizeof(u32_t));
    if(0 == count){
        SpxLogFmt1(c->log,SpxLogMark,
                "no sync storages from tracker:%s:%d",
                t->host.ip,t->host.port);
        goto r1;
    }
    u64_t secs = spx_now();
    u32_t i = 0;
    for( ; i < count ; i++){
        string_t machineid = spx_msg_unpack_string(ctx,YDB_MACHINEID_LEN,&err);
        string_t ip = spx_msg_unpack_string(ctx,SpxIpv4Size,&err);
        i32_t port = spx_msg_unpack_i32(ctx);
        u32_t state = spx_msg_unpack_i32(ctx);
        bool_t is_stop_recv_sync = false;
        if(!spx_msg_isend(ctx)){
            is_stop_recv_sync = spx_msg_unpack_bool(ctx);
        }

        SpxLogFmt1(c->log,SpxLogInfo,
                "get remote storage:%s,state:%s.",
                machineid,
                ydb_state_desc[state]);

        struct ydb_storage_remote *remote_storage = NULL;
        remote_storage = spx_map_get(g_ydb_remote_storages,
                machineid,spx_string_rlen(machineid),NULL);
        if(NULL != remote_storage){
            SpxStringFree(machineid);//machineid is the same,so not useful
            remote_storage->runtime_state = state;
            if(NULL == remote_storage->host.ip) {
                remote_storage->host.ip = ip;
            } else {
                if(0 != spx_string_cmp(ip,remote_storage->host.ip)){
                    SpxStringFree(remote_storage->host.ip);
                    remote_storage->host.ip = ip;
                } else {
                    SpxStringFree(ip);
                }
            }
            if(port != remote_storage->host.port){
                remote_storage->host.port = port;
            }
            remote_storage->update_timespan = secs;
            remote_storage->is_stop_recv_sync = is_stop_recv_sync;
        } else {
            remote_storage = (struct ydb_storage_remote *)
                spx_alloc_alone(sizeof(struct ydb_storage_remote),&err);
            if(NULL == remote_storage){
                SpxLogFmt2(c->log,SpxLogError,err,
                        "new sync remote storage:%s get from tracker:%s:%d is fail.",
                        machineid,t->host.ip,t->host.port);
                continue;
            }
            remote_storage->c = c;
            remote_storage->machineid = machineid;
            remote_storage->runtime_state = state;
            remote_storage->host.ip = ip;
            remote_storage->host.port = port;
            remote_storage->is_stop_recv_sync = is_stop_recv_sync;
            remote_storage->update_timespan = secs;
            if(0 != (err = spx_map_insert(g_ydb_remote_storages,
                            machineid,spx_string_rlen(machineid),
                            remote_storage,sizeof(remote_storage)))){
                SpxLogFmt2(c->log,SpxLogError,err,
                        "new sync remote storage:%s get from tracker:%s:%d is fail.",
                        machineid,t->host.ip,t->host.port);
                continue;
            }
        }
    }
r1:
    spx_job_context_clear(jc);
}/*}}}*/

pthread_t ydb_storage_sync_heartbeat_service_init(
        SpxLogDelegate *log,
        u32_t timeout,
        u32_t waitting,
        u32_t trytimes,
        struct ydb_storage_configurtion *config,\
        err_t *err){/*{{{*/
    struct spx_job_context_transport arg;
    SpxZero(arg);
    arg.timeout = timeout;
    arg.waitting = waitting;
    arg.trytimes = trytimes;
    arg.nio_reader = spx_nio_reader_with_timeout_fast;
    arg.nio_writer = spx_nio_writer_with_timeout_fast;
    arg.log = log;
    arg.verifyHeaderHandler = NULL;
    arg.disposeWriterHandler = ydb_storage_sync_heartbeat_nio_writer;
    arg.disposeReaderHandler = ydb_storage_sync_heartbeat_nio_reader;
    arg.config = config;
    sync_heartbet_timer = spx_alloc_alone(sizeof(*sync_heartbet_timer),err);
    if(NULL == sync_heartbet_timer){
        SpxLog2(log,SpxLogError,*err,"alloc sync heartbeat timer is fail.");
        goto r1;
    }
    sync_heartbet_timer->data = config;
    sync_heart_loop = ev_loop_new(0);
    if(NULL == sync_heart_loop){
        *err = errno;
        SpxLog2(log,SpxLogError,*err,\
                "new event loop for sync heartbeat is fail.");
        goto r1;
    }

    struct spx_thread_context * tc = spx_thread_context_new_alone(log,err);
    tc->loop = sync_heart_loop;
    struct spx_vector_iter *iter = spx_vector_iter_new(config->trackers ,err);
    if(NULL == iter){
        SpxLog2(log,SpxLogError,*err,\
                "init the trackers iter is fail.");
        goto r1;
    }

    bool_t isrun = true;
    do{
        struct ydb_tracker *t = NULL;
        while(NULL != (t = spx_vector_iter_next(iter))){
            if(NULL == t->sync_heartbeat_jc){
                t->sync_heartbeat_jc = (struct spx_job_context *) spx_job_context_new(0,&arg,err);
                if(NULL == t->sync_heartbeat_jc){
                    isrun = false;
                    SpxLog2(log,SpxLogError,*err,"alloc sync heartbeat nio context is fail.");
                    break;
                }
                t->sync_heartbeat_jc->tc = tc;
            }
        }
    }while(false);
    spx_vector_iter_free(&iter);
    if(!isrun){
        goto r1;
    }

//    if(0 != (*err = ydb_storage_sync_heartbeat_query_storages_once(config))) {
//        SpxLog2(config->log,SpxLogError,*err,
//                "query storage once is fail.");
//        goto r1;
//    }

    ydb_storage_sync_heartbeat_query_storages_once(config);

    pthread_t tid = 0;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    size_t ostack_size = 0;
    pthread_attr_getstacksize(&attr, &ostack_size);
    do{
        if (ostack_size != config->stacksize
                && (0 != (*err = pthread_attr_setstacksize(&attr,config->stacksize)))){
            pthread_attr_destroy(&attr);
            SpxLog2(log,SpxLogError,*err,\
                    "set thread stack size is fail.");
            goto r1;
        }
        if (0 !=(*err =  pthread_create(&(tid), &attr, ydb_storage_sync_heartbeat_regedit_timer,
                        config))){
            pthread_attr_destroy(&attr);
            SpxLog2(log,SpxLogError,*err,\
                    "create heartbeat thread is fail.");
            goto r1;
        }
    }while(false);
    pthread_attr_destroy(&attr);
    return tid;
r1:
    if(NULL != sync_heartbet_timer){
        SpxFree( sync_heartbet_timer);
    }
    return 0;
}/*}}}*/






