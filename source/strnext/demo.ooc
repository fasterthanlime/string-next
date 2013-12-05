// sdk
import structs/ArrayList

// ours
import strnext/Str

main: func {
    s := S(c"Hello, world. ")

    "== print" println()
    s println()

    "== 0th char" println()
    s[0] println()

    "== modified 1st char" println()
    s[1] = 'a'
    s[1] println()

    s2 := S(c"You're pretty today :)")
    s3 := s + s2

    "== s3" println()
    s3 println()

    "== printfln" println()
    "%s" printfln(s data)

    list := [s, s2, s3] as ArrayList<Str>
    for ((i, l) in list) {
        "== list[#{i}] = " println()
        l println()
    }

    "== freezing s" println()
    s freeze!()

    try {
        s[1] = 'e'
        "== should have gotten exception" println()
        exit(1)
    } catch (e: Exception) {
        "== got exception as expected: \"#{e message}\"" println()
    }

    "== cloning and modifying" println()
    sb := s clone()
    sb[1] = 'e'
    sb println()

    "== buf" println()
    b := Buf new()
    b << s
    b << s
    b toString() println()

    idx1 := s indexOf('l')
    "== index 1 of l: #{idx1}" println()
    "== index 2 of l: #{s indexOf('l', idx1 + 1)}" println()
    "== index of pretty : #{s2 indexOf(S(c"pretty"))}" println()

    s2up := s2 upcase()
    s2dw := s2 downcase()
    "== s2 upcase :" println()
    s2up println()
    "== s2 downcase :" println()
    s2dw println()
}

S: func (c: CString) -> Str {
    Str new~literal(c)
}

