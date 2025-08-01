//===-- Implementation header for pthread_barrier_init ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_PTHREAD_PTHREAD_BARRIER_INIT_H
#define LLVM_LIBC_SRC_PTHREAD_PTHREAD_BARRIER_INIT_H

#include "hdr/types/pthread_barrier_t.h"
#include "hdr/types/pthread_barrierattr_t.h"
#include "src/__support/macros/config.h"

namespace LIBC_NAMESPACE_DECL {

int pthread_barrier_init(pthread_barrier_t *b,
                         const pthread_barrierattr_t *__restrict attr,
                         unsigned count);

} // namespace LIBC_NAMESPACE_DECL

#endif // LLVM_LIBC_SRC_PTHREAD_PTHREAD_BARRIER_INIT_H
