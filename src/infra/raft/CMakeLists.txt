cmake_minimum_required(VERSION 3.12)
project(infra_raft)
MESSAGE(STATUS "processing infra_raft")

# Generated sources
set(raft_generated_dir "generated")
file(MAKE_DIRECTORY ${raft_generated_dir})

# raft.proto and streaming.proto
set(proto_file_list raft.proto streaming.proto)
ADD_PROTO_SET(raft_proto_library "${proto_file_list}" ${raft_generated_dir})

# Include generated *.pb.h files
include_directories("${raft_generated_dir}")

# Source files
set(INFRA_RAFT_SRC
        metrics/RaftMetrics.cpp
        metrics/RaftMonitorAdaptor.cpp
        RaftLogStore.cpp
        RaftReplyLoop.cpp
        StreamingService.cpp
        storage/Segment.cpp
        storage/SegmentLog.cpp
        v2/RaftCore.cpp
        v2/RaftService.cpp)

# Library
add_library(infra_raft STATIC
        ${INFRA_RAFT_SRC})
add_dependencies(infra_raft raft_proto_library)
target_link_libraries(infra_raft raft_proto_library)

# Executables
add_executable(StorageMain StorageMain.cpp)
target_link_libraries(StorageMain infra_raft raft_proto_library infra_util ${LIBRARIES})

set(BOOST_SHARED_LIBS
        boost_system.so
        boost_thread.so
        boost_filesystem.so
        boost_iostreams.so)

set(ROCKSDB_SHARED_LIBS
        bz2.so)

set(ROCKSDB_STATIC_LIBS
        rocksdb.a
        gflags.a
        snappy.a
        lz4.a
        zstd.a)


set(STATIC_LIB rt sqlite3.a pthread dl ${ABSL_LIBS} ${OPENSSL_LIBS}
        ${MONITOR_LIBS} ${ROCKSDB_STATIC_LIBS} ${_GRPC_GRPCPP} ${_PROTOBUF_LIBPROTOBUF} lib_inih)

set(SHARED_LIB ${BOOST_SHARED_LIBS} ${ROCKSDB_SHARED_LIBS})

add_library(infra_shared SHARED
        ${INFRA_RAFT_SRC})
target_link_libraries(infra_shared raft_proto_library infra_util infra_monitor ${STATIC_LIB} ${SHARED_LIB})
