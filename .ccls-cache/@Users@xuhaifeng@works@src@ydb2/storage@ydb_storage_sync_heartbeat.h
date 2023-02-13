#ifndef _YDB_STORAGE_SYNC_HEARTBEAT_
#define _YDB_STORAGE_SYNC_HEARTBEAT_
#ifdef __cplusplus
extern "C" {
#endif


#include <pthread.h>
#include <ev.h>


#include "spx_types.h"
#include "spx_map.h"
#include "spx_job.h"

#include "ydb_protocol.h"
#include "ydb_storage_binlog.h"
#include "ydb_storage_synclog.h"
#include "ydb_storage_dio_context.h"
#include "ydb_storage_runtime.h"

#include "ydb_storage_configurtion.h"

#define YDB_CSYNC_NOT_MAKED_STATE_MACHINE_ERRNO 2015

#define YDB_STORAGE_CSYNC_LIFECYCLE_BEGIN 0
#define YDB_STORAGE_CSYNC_LIFECYCLE_QUERY_REMOTE_TIMESPANE 1
#define YDB_STORAGE_CSYNC_LIFECYCLE_MAKE_STATE_MACHINE 2
#define YDB_STORAGE_CSYNC_LIFECYCLE_SYNCING 3

struct ydb_storage_remote{
    struct ydb_storage_configurtion *c;
    string_t machineid;
    struct spx_host host;
    i32_t runtime_state;
    u64_t update_timespan;
    u64_t first_startup_time;
    struct {
        struct spx_date date;
        FILE *fp;
        u64_t offset;
        string_t fname;
    }read_binlog;
    struct ydb_storage_synclog synclog;
    bool_t exist_remote_binlog_offset;
    u64_t remote_binlog_offset;
    bool_t is_doing;
    bool_t is_maked_csync_state_machine;
    ev_async async;
    ev_stat stat;
    ev_timer timer;
    struct spx_job_context *jc;
    //the jc is for query remote storage that the local storage can online
    struct spx_job_context *jc_online;
    string_t line;
    u32_t linelength;
    int retry;
    int retry_count;
    int op;
    struct ydb_storage_fid *fid;
    bool_t csync_end;//the remote storage do csyncing is over
    bool_t can_online;//get the remote storage statue by heartbeat online timer
    char mps[256];
    bool_t is_query_mountpoint;
    bool_t is_stop_recv_sync;
};


extern struct spx_map *g_ydb_remote_storages;


pthread_t ydb_storage_sync_heartbeat_service_init(
        SpxLogDelegate *log,
        u32_t timeout,
        u32_t waitting,
        u32_t trytimes,
        struct ydb_storage_configurtion *config,\
        err_t *err);

#ifdef __cplusplus
}
#endif
#endif
