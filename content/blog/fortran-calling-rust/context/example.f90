program example

    use rust_interface

    implicit none

    call initialize()

    print *, "result of query:", query()
    print *, "result of query:", query()
    print *, "result of query:", query()
    print *, "result of query:", query()
    print *, "result of query:", query()

    call finalize()

end program
