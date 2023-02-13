/*
 * =====================================================================================
 *
 * this software or lib may be copied only under the terms of the gnu general
 * public license v3, which may be found in the source kit.
 *
 *       Filename:  ydb_storage_dio_context.h
 *        Created:  2014/08/07 13时45分50秒
 *         Author:  Seapeak.Xu (seapeak.cnblog.com), xvhfeng@gmail.com
 *        Company:  Tencent Literature
 *         Remark:
 *
 * =====================================================================================
 */
#ifndef _YDB_STORAGE_DIO_CONTEXT_H_
#define _YDB_STORAGE_DIO_CONTEXT_H_
#ifdef __cplusplus
extern "C" {
#endif


#include <stdlib.h>
#include <stdio.h>
#include <ev.h>

#include "spx_types.h"
#include "spx_job.h"
#include "spx_task.h"
#include "spx_fixed_vector.h"
#include "spx_message.h"

#include "ydb_storage_configurtion.h"
#include "ydb_storage_storefile.h"

#define YdbBufferSizeForLazyRecv 10 * 1024

    struct ydb_storage_singlefile {
        u8_t mpidx;
        u8_t p1;
        u8_t p2;
        int fd;
        char *mptr;
        size_t fsize;
        u64_t offset;
        u64_t fcreatetime;
        u32_t rand;
        string_t filename;//must exist
        string_t machineid;
        u32_t tidx;
    };

    struct ydb_storage_ofile_context {
        string_t o_groupname;
        string_t o_machineid;
        string_t o_syncgroup;
        string_t o_hashcode ;
        bool_t o_issinglefile;
        string_t o_suffix ;
        u8_t o_mpidx ;
        u8_t o_p1 ;
        u8_t o_p2 ;
        u32_t o_tidx ;
        u64_t o_fcreatetime;
        u32_t o_rand;
        u64_t o_begin;
        u64_t o_realsize ;
        u64_t o_totalsize;
        u32_t o_ver ;
        u32_t o_opver;
        u64_t o_lastmodifytime;
        u64_t o_client_finger;
        bool_t o_has_suffix ;
        string_t o_fname ;
    };


    struct ydb_storage_dio_context{
        ev_async async;
        size_t idx;
        SpxLogDelegate *log;
        struct ydb_storage_configurtion *c;
		
		//csync protocol ext
		u32_t v2_data_count;
		u32_t v2_mapping_size;
        u32_t v2_data_size;
        u32_t v2_data_index;
        u32_t v2_old_begin;
		u32_t v2_new_begin;

        u32_t ver;//version for suppert operator
        u32_t opver;//the operator in the chunk data version
        err_t err;

        bool_t isdelete;
        u64_t createtime;// the buffer put into the disk time first time
        u64_t lastmodifytime;//the buffer last modify
        string_t hashcode;//length 64,now the operator is space and no useful
        u64_t totalsize;//if file is single file totalsize == realsize
        u64_t realsize;
        u64_t client_finger;//the id from client,maybe it is 0
        bool_t has_client_finger;

        string_t groupname;// from configurtion
        string_t machineid;//same as above
        string_t syncgroup;
        u64_t file_createtime;//if it is single file then the operator equ creattime
        u8_t mp_idx;
        u8_t p1;//path of level 1
        u8_t p2;//path of level 2
        u32_t tidx;
        u32_t rand;
        bool_t issinglefile;
        u64_t begin;
        bool_t has_suffix;
        string_t suffix;

        struct spx_job_context *jc;
        struct spx_task_context *tc;
        struct ydb_storage_storefile *storefile;//disk file for put into buffer

        //network buffer for lazy recv,
        char *buf;
        //the rfid is recv fileid from client
        //it support for modify,delete,and find
        string_t rfid;
        //the fid is making by storage to return to client
        string_t fid;

//        string_t filename;
        struct spx_msg *metadata;//if the file is chunkfile the member store metadata

        struct spx_date *date;
        string_t sync_machineid;// the machineid use for sync means operator machineid

        struct ydb_storage_singlefile sf;
        struct ydb_storage_ofile_context *ofc;//just only for modify
    };

    struct ydb_storage_dio_pool{
        SpxLogDelegate *log;
        struct spx_fixed_vector *pool;
    };

    extern struct ydb_storage_dio_pool *g_ydb_storage_dio_pool;

    struct ydb_storage_dio_pool *ydb_storage_dio_pool_new(SpxLogDelegate *log,\
            struct ydb_storage_configurtion *c,
            size_t size,\
            err_t *err);

    struct ydb_storage_dio_context *ydb_storage_dio_pool_pop(\
            struct ydb_storage_dio_pool *pool,\
            err_t *err);

    err_t ydb_storage_dio_pool_push(\
            struct ydb_storage_dio_pool *pool,\
            struct ydb_storage_dio_context *dc);

    err_t ydb_storage_dio_pool_free(struct ydb_storage_dio_pool **pool);


#ifdef __cplusplus
}
#endif
#endif
