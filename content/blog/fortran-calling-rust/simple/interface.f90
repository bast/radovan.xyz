module rust_interface

    use, intrinsic :: iso_c_binding, only: c_int32_t, c_double

    implicit none

    interface
        function sum_two_integers(a, b) result(output) bind(c)
            import :: c_int32_t
            integer(c_int32_t), intent(in), value :: a
            integer(c_int32_t), intent(in), value :: b
            integer(c_int32_t) :: output
        end function

        function sum_two_doubles(a, b) result(output) bind(c)
            import :: c_double
            real(c_double), intent(in), value :: a
            real(c_double), intent(in), value :: b
            real(c_double) :: output
        end function

        function sum_integer_array(data, size) result(output) bind(c)
            import :: c_int32_t
            integer(c_int32_t), intent(in) :: data(*)
            integer(c_int32_t), intent(in), value :: size
            integer(c_int32_t) :: output
        end function
    end interface

end module
