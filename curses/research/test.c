#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <errno.h>
#include <signal.h>

#define	SOCK_FILE	"test.sock"

int sock;
bool is_exit = 0;

void signal_handler(int signum) {
  is_exit = 1;
  shutdown(sock, SHUT_RDWR);
  close(sock);
}

int main(int argc, char **argv)
{
  if (SIG_ERR == signal(SIGINT, signal_handler)) {
    printf("register signal handler faled. errno=%d\n", errno);
    return 1;
  }

  if (-1 == (sock = socket(AF_UNIX, SOCK_STREAM, 0))) {
    printf("socket create faled. errno=%d\n", errno);
    return 1;
  }

  struct sockaddr_un unix_addr;
  unix_addr.sun_family = AF_UNIX;
  strcpy(unix_addr.sun_path, SOCK_FILE);

  if (-1 == bind(sock, (struct sockaddr *)&unix_addr, sizeof(unix_addr))) {
    printf("socket bind faled. errno=%d\n", errno);
    goto ERR;
  }

  int ret = 0;

  while (0 == listen(sock, 32)) {
    socklen_t len = sizeof(unix_addr);
    int fd = accept(sock, (struct sockaddr *)&unix_addr, &len);
    if (-1 == fd) {
      if (!is_exit) {
        printf("accept faild. errno=%d\n", errno);
        ret = 1;
      }

      break;
    }

    unsigned char buf[256] = {0};
    if (-1 == recv(fd, buf, sizeof(buf), 0)) {
      printf("recv faild. errno=%d\n", errno);
      ret = 1;
      break;
    }

    printf("recv: %02X %02X %02X %02X %02X\n", buf[0], buf[1], buf[2], buf[3], buf[4]);
  }

ERR:
  unlink(SOCK_FILE);

  return 1;
}

