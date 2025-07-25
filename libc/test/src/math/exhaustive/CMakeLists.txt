add_libc_exhaustive_testsuite(libc_math_exhaustive_tests)

add_header_library(
  exhaustive_test
  HDRS
    exhaustive_test.h
  DEPENDS
    libc.src.__support.CPP.type_traits
    libc.src.__support.FPUtil.fp_bits
    libc.src.__support.macros.properties.types
)

add_fp_unittest(
  sqrtf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    sqrtf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.sqrtf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  sinf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    sinf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.sinf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  sinpif_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    sinpif_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.sinpif
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  cosf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    cosf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.cosf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  cospif_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    cospif_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.cospif
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  sincosf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    sincosf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.sincosf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  tanf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    tanf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.tanf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  tanpif_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    tanpif_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.tanpif
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  erff_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    erff_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.erff
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  expf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    expf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.expf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  exp2f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    exp2f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.exp2f
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  exp2m1f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    exp2m1f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.exp2m1f
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  exp10f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    exp10f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.exp10f
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  exp10m1f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    exp10m1f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.exp10m1f
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  expm1f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    expm1f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.expm1f
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  logf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    logf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.logf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  log10f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    log10f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.log10f
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  log1pf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    log1pf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.log1pf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  log2f_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    log2f_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.log2f
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  hypotf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    hypotf_test.cpp
  COMPILE_OPTIONS
    ${libc_opt_high_flag}
  DEPENDS
    .exhaustive_test
    libc.src.math.hypotf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  hypotf16_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    hypotf16_test.cpp
  COMPILE_OPTIONS
    ${libc_opt_high_flag}
  DEPENDS
    .exhaustive_test
    libc.src.math.hypotf16
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  fmod_generic_impl_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    fmod_generic_impl_test.cpp
  DEPENDS
    libc.src.__support.FPUtil.fp_bits
    libc.src.__support.FPUtil.manipulation_functions
    libc.src.__support.FPUtil.generic.fmod
)

add_fp_unittest(
  fmodf16_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    fmodf16_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.fmodf16
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  coshf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    coshf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.coshf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  sinhf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    sinhf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.sinhf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  tanhf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    tanhf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.tanhf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  acoshf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    acoshf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.acoshf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  asinhf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    asinhf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.asinhf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  atanhf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    atanhf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.atanhf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  atanf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    atanf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.atanf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  asinf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    asinf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.asinf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  acosf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    acosf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.acosf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  f16sqrtf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    f16sqrtf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.f16sqrtf
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  cbrtf_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    cbrtf_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.math.cbrtf
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)

add_fp_unittest(
  bfloat16_test
  NO_RUN_POSTBUILD
  NEED_MPFR
  SUITE
    libc_math_exhaustive_tests
  SRCS
    bfloat16_test.cpp
  DEPENDS
    .exhaustive_test
    libc.src.__support.FPUtil.bfloat16
    libc.src.__support.FPUtil.fp_bits
  LINK_LIBRARIES
    -lpthread
)
