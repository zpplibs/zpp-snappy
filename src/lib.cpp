#include <zpp-snappy.h>
#include <snappy.h>

extern "C" {

/// Returns 0 for success
/// 1 for append failure
/// 2 for operation failure
uint8_t
zpp_snappy(
    const bool compress,
    const char* data, const size_t data_len,
    const void* list_ptr
) {
    uint8_t ret;
    std::string out;
    if (compress) {
        ret = 0 < snappy::Compress(data, data_len, &out) ? 0 : 2;
    } else {
        ret = snappy::Uncompress(data, data_len, &out) ? 0 : 2;
    }
    if (ret == 0) {
        ret = zpp_array_list_u8_append_slice(list_ptr, out.data(), out.size()) ? 0 : 1;
    }
    return ret;
}

bool
zpp_snappy_ss(
    const bool compress,
    const char* data, const size_t data_len,
    const intptr_t ss_ptr, size_t* ss_len,
    char** buf_out, size_t* capacity_out
) {
    auto buf = (std::string*)ss_ptr;
    auto len = *ss_len;
    auto current_size = buf->size();
    if (len < current_size) {
        // shrink
        buf->resize(len);
    } else if (len > current_size && 0 < (len = buf->capacity() - current_size)) {
        // move to end
        buf->append(buf->data() + current_size, len);
    }
    
    const char* buf_data = buf->data();
    bool ok = compress ? 0 < snappy::Compress(data, data_len, buf) :
            snappy::Uncompress(data, data_len, buf);
    if (ok) {
        *ss_len = buf->size();
        if (buf_data != buf->data()) {
            // expanded
            *buf_out = const_cast<char*>(buf->data());
            *capacity_out = buf->capacity();
        }
    }
    return ok;
}

/// Returns 0 on failure
size_t
zpp_snappy_get_uncompressed_len(
    const char* data, const size_t data_len
) {
    size_t result;
    return snappy::GetUncompressedLength(data, data_len, &result) ? result : 0;
}

} // "C"
