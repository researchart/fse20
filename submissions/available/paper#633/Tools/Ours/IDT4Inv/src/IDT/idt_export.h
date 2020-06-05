
#ifndef IDT_EXPORT_H
#define IDT_EXPORT_H

#ifdef IDT_STATIC_DEFINE
#  define IDT_EXPORT
#  define IDT_NO_EXPORT
#else
#  ifndef IDT_EXPORT
#    ifdef IDT_EXPORTS
        /* We are building this library */
#      define IDT_EXPORT 
#    else
        /* We are using this library */
#      define IDT_EXPORT 
#    endif
#  endif

#  ifndef IDT_NO_EXPORT
#    define IDT_NO_EXPORT 
#  endif
#endif

#ifndef IDT_DEPRECATED
#  define IDT_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef IDT_DEPRECATED_EXPORT
#  define IDT_DEPRECATED_EXPORT IDT_EXPORT IDT_DEPRECATED
#endif

#ifndef IDT_DEPRECATED_NO_EXPORT
#  define IDT_DEPRECATED_NO_EXPORT IDT_NO_EXPORT IDT_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef IDT_NO_DEPRECATED
#    define IDT_NO_DEPRECATED
#  endif
#endif

#endif /* IDT_EXPORT_H */
