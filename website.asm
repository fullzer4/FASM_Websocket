format ELF64 executable

include 'constants.asm'
include 'macros.asm'

segment readable executable
entry main
main:

    write STDOUT, start, start_len

    write STDOUT, socket_trace_msg, socket_trace_msg_len

    socket AF_INET, SOCK_STREAM, 0 ;; run correct
    ;;socket 69, 420, 0 ;; run error
    cmp rax, 0
    jl error

    mov qword [sockfd], rax

    write STDOUT, bind_trace_msg, bind_trace_msg_len
    mov word [servaddr.sin_family], AF_INET
    mov dword [servaddr.sin_addr], INADDR_ANY
    mov word [servaddr.sin_port], 14619 ;6969
    bind [sockfd], servaddr.sin_family, servaddr.size
    cmp rax, 0
    jl error

    write STDOUT, listen_trace_msg, listen_trace_msg_len
    listen [sockfd], MAX_CONN
    cmp rax, 0
    jl error

    write STDOUT, ok_msg, ok_msg_len
    close [sockfd]
    exit 0

error:
    write STDERR, error_msg, error_msg_len
    close [sockfd]
    exit 1

;; db - 1 byte
;; dw - 2 byte
;; dd - 4 byte
;; dq - 8 byte

segment readable writeable

struc servaddr_in
{
    .sin_family dw 0
    .sin_port dw 0
    .sin_addr dd 0
    .sin_zero dq 0
    .size = .sin_family - $
}

sockfd dq 0
servaddr servaddr_in
cliaddr servaddr_in

start db "INFO: Starting web server!", 10
start_len = $ - start
ok_msg db "INFO: Created!", 10
ok_msg_len = $ - ok_msg
socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg
bind_trace_msg db "INFO: Binding the socket...", 10
bind_trace_msg_len = $ - bind_trace_msg
listen_trace_msg db "INFO: Listening to the socket...", 10
listen_trace_msg_len = $ - listen_trace_msg
error_msg db "ERROR!", 10
error_msg_len = $ - error_msg