program example

    use rust_interface

    implicit none

    integer, allocatable :: integer_array_1d(:)
    integer, allocatable :: integer_array_2d(:, :)
    real(8), allocatable :: array_doubles(:, :)


    allocate(integer_array_1d(5))
    integer_array_1d = [1, 2, 3, 4, 5]

    print *, "sum of 1D array:", &
            sum_integer_array(integer_array_1d, size(integer_array_1d))

    call modify_array(integer_array_1d, size(integer_array_1d))

    print *, "after modification:", &
            sum_integer_array(integer_array_1d, size(integer_array_1d))

    deallocate(integer_array_1d)


    allocate(array_doubles(2, 3))

    array_doubles(1, 1) = 1.0d0
    array_doubles(1, 2) = 2.0d0
    array_doubles(1, 3) = 3.0d0
    array_doubles(2, 1) = 4.0d0
    array_doubles(2, 2) = 5.0d0
    array_doubles(2, 3) = 6.0d0

    call check_array_order(array_doubles, size(array_doubles))

    deallocate(array_doubles)

end program
