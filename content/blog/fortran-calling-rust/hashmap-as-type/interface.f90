module rust_interface

    use, intrinsic :: iso_c_binding, only: c_ptr, c_int32_t, c_null_ptr

    implicit none

    type :: map
        type(c_ptr) :: handle
    contains
        procedure :: init    => wrap_create_map
        procedure :: insert  => wrap_insert_into_map
        procedure :: get     => wrap_get_from_map
        procedure :: destroy => wrap_destroy_map
    end type

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

contains

    subroutine wrap_create_map(this)
        class(map), intent(out) :: this

        this%handle = create_map()
    end subroutine


    subroutine wrap_insert_into_map(this, key, val)
        class(map), intent(inout) :: this
        integer(c_int32_t), intent(in), value :: key, val

        call insert_into_map(this%handle, key, val)
    end subroutine


    function wrap_get_from_map(this, key) result(val)
        class(map), intent(in) :: this
        integer(c_int32_t), intent(in), value :: key
        integer(c_int32_t) :: val

        ! no error handling if key is not found
        val = get_from_map(this%handle, key)
    end function


    subroutine wrap_destroy_map(this)
        class(map), intent(inout) :: this

        call destroy_map(this%handle)
        this%handle = c_null_ptr
    end subroutine

end module
