#pragma once

#include <zpp.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Returns 0 for success
/// 1 for append failure
/// 2 for operation failure
uint8_t
zpp_snappy(
    const bool compress,
    const char* data, const size_t data_len,
    const void* list_ptr
);

bool
zpp_snappy_ss(
    const bool compress,
    const char* data, const size_t data_len,
    const intptr_t ss_ptr, size_t* ss_len,
    char** buf_out, size_t* capacity_out
);

/// Returns 0 on failure
size_t
zpp_snappy_get_uncompressed_len(
    const char* data, const size_t data_len
);

#ifdef __cplusplus
}
#endif