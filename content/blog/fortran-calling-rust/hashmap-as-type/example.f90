program example

    use rust_interface

    implicit none

    type(map) :: map1, map2

    call map1%init()
    call map2%init()

    call map1%insert(10, 100)
    call map1%insert(20, 200)

    call map2%insert(20, 300)
    call map2%insert(30, 400)

    print *, map1%get(10)
    print *, map1%get(20)
    print *, map2%get(20)

    ! retrieve a non-existent key
    print *, map2%get(99)

    print *, map1%get(20)
    call map1%insert(20, 222)
    print *, map1%get(20)

    call map1%destroy()
    call map2%destroy()

end program
