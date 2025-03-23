module rust_interface

    use, intrinsic :: iso_c_binding, only: c_int32_t, c_double

    implicit none

    interface
        function sum_integer_array(data, size) result(output) bind(c)
            import :: c_int32_t
            integer(c_int32_t), intent(in) :: data(*)
            integer(c_int32_t), intent(in), value :: size
            integer(c_int32_t) :: output
        end function

        subroutine modify_array(data, size) bind(c)
            import :: c_int32_t
            integer(c_int32_t), intent(inout) :: data(*)
            integer(c_int32_t), intent(in), value :: size
        end subroutine

        subroutine check_array_order(data, size) bind(c)
            import :: c_double, c_int32_t
            real(c_double), intent(in) :: data(*)
            integer(c_int32_t), intent(in), value :: size
        end subroutine
    end interface

end module
