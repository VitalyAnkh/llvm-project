// RUN: %check_clang_tidy %s concurrency-mt-unsafe %t -- -config='{CheckOptions: {concurrency-mt-unsafe.FunctionSet: "glibc"}}'

extern unsigned int sleep (unsigned int __seconds);
extern int *gmtime (const int *__timer);
extern char *dirname (char *__path);
extern char *strerror(int errnum);

void foo() {
  sleep(2);
  // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: function is not thread safe [concurrency-mt-unsafe]

  ::sleep(2);
  // CHECK-MESSAGES: :[[@LINE-1]]:3: warning: function is not thread safe [concurrency-mt-unsafe]

  dirname(nullptr);

  strerror(0);
}
