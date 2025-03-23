module rust_interface

    use, intrinsic :: iso_c_binding, only: c_ptr, c_int32_t

    implicit none

    interface
        function create_map() bind(c)
            import :: c_ptr
            type(c_ptr) :: create_map
        end function

        subroutine insert_into_map(context, key, val) bind(c)
            import :: c_ptr, c_int32_t
            type(c_ptr), value :: context
            integer(c_int32_t), intent(in), value :: key, val
        end subroutine

        function get_from_map(context, key) result(val) bind(c)
            import :: c_ptr, c_int32_t
            type(c_ptr), value :: context
            integer(c_int32_t), intent(in), value :: key
            integer(c_int32_t) :: val
        end function

        subroutine destroy_map(context) bind(c)
            import :: c_ptr
            type(c_ptr), value :: context
        end subroutine
    end interface

end module
