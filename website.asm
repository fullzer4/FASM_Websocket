format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
SYS_socket equ 41
SYS_bind equ 49
SYS_listen equ 50
SYS_close equ 3

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

MAX_CONN equ 5

macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b, c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

macro write fd, buf, count 
{
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro close fd
{
    syscall1 SYS_close, fd
}

macro socket domain, type, protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

macro bind sockfd, addr, addrlen
{
    syscall3 SYS_bind, sockfd, addr, addrlen
}

macro listen sockfd, backlog
{
    syscall2 SYS_listen, sockfd, backlog
}

macro exit code
{
    mov rax, SYS_exit
    mov rdi, code
    syscall 
}

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