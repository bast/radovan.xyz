program example

    use rust_interface

    implicit none

    integer, allocatable :: integer_array_1d(:)
    integer, allocatable :: integer_array_2d(:, :)


    print *, "sum of two integers:", sum_two_integers(2, 3)
    print *, "sum of two doubles:", sum_two_doubles(2.0d0, 3.0d0)


    allocate(integer_array_1d(5))
    integer_array_1d = [1, 2, 3, 4, 5]
    print *, "sum of 1D array:", &
            sum_integer_array(integer_array_1d, size(integer_array_1d))
    deallocate(integer_array_1d)


    allocate(integer_array_2d(2, 3))
    integer_array_2d = 1
    print *, "sum of 2D array:", &
            sum_integer_array(integer_array_2d, size(integer_array_2d))
    deallocate(integer_array_2d)

end program
