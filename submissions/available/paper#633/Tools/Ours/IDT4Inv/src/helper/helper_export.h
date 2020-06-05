
#ifndef HELPER_EXPORT_H
#define HELPER_EXPORT_H

#ifdef HELPER_STATIC_DEFINE
#  define HELPER_EXPORT
#  define HELPER_NO_EXPORT
#else
#  ifndef HELPER_EXPORT
#    ifdef Helper_EXPORTS
        /* We are building this library */
#      define HELPER_EXPORT 
#    else
        /* We are using this library */
#      define HELPER_EXPORT 
#    endif
#  endif

#  ifndef HELPER_NO_EXPORT
#    define HELPER_NO_EXPORT 
#  endif
#endif

#ifndef HELPER_DEPRECATED
#  define HELPER_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef HELPER_DEPRECATED_EXPORT
#  define HELPER_DEPRECATED_EXPORT HELPER_EXPORT HELPER_DEPRECATED
#endif

#ifndef HELPER_DEPRECATED_NO_EXPORT
#  define HELPER_DEPRECATED_NO_EXPORT HELPER_NO_EXPORT HELPER_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef HELPER_NO_DEPRECATED
#    define HELPER_NO_DEPRECATED
#  endif
#endif

#endif /* HELPER_EXPORT_H */
