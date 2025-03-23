program example

    use, intrinsic :: iso_c_binding, only: c_ptr
    use rust_interface

    implicit none

    type(c_ptr) :: map1, map2

    map1 = create_map()
    map2 = create_map()

    call insert_into_map(map1, 10, 100)
    call insert_into_map(map1, 20, 200)

    call insert_into_map(map2, 20, 300)
    call insert_into_map(map2, 30, 400)

    print *, get_from_map(map1, 10)
    print *, get_from_map(map1, 20)
    print *, get_from_map(map2, 20)

    ! retrieve a non-existent key
    print *, get_from_map(map2, 99)

    print *, get_from_map(map1, 20)
    call insert_into_map(map1, 20, 222)
    print *, get_from_map(map1, 20)

    call destroy_map(map1)
    call destroy_map(map2)

end program
