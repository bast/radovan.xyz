module rust_interface

    use, intrinsic :: iso_c_binding, only: c_int32_t

    implicit none

    interface
        subroutine initialize() bind(c)
        end subroutine

        function query() result(output) bind(c)
            import :: c_int32_t
            integer(c_int32_t) :: output
        end function

        subroutine finalize() bind(c)
        end subroutine
    end interface

end module
