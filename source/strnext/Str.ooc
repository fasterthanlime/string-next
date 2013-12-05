
Str: cover {

    /*
     * A sequence of bytes
     */
    data: Char*

    /*
     * Number of bytes to be interpreted as characters
     */
    size: Int

    /**
     * Number of bytes available in data.
     * -1 means 'copy on write', -2 means 'frozen'
     */
    capacity: Int

    /* CONSTRUCTORS */

    /**
     * Make a new zero-copy String out of a CString
     */
    new: final static func ~literal (c: CString) -> This {
        (c, strlen(c), -1) as This
    }

    /* ACCESS */

    get: func (i: Int) -> Char {
        _checkIndex(i)
        data[i]
    }

    set!: func@ (i: Int, c: Char) {
        touch!()
        _checkIndex(i)
        data[i] = c
    }

    /** Identity function */
    toString: func -> This {
        this
    }

    /* COMPARISON */

    equals?: func (other: This) -> Bool {
        if (other size != size) {
            return false
        }
        memcmp(data, other data, size) == 0
    }

    /* SEARCH AND REPLACE */

    indexOf: func ~str (needle: This, startIndex := 0) -> Int {
        for (offset in startIndex..size) {
            if (offset + needle size > size) {
                // no room for the needle at this point
                return -1
            }
            if (memcmp(data + offset, needle data, needle size) == 0) {
                // found it!
                return offset
            }
        }

        -1
    }

    indexOf: func ~char (needle: Char, startIndex := 0) -> Int {
        for (offset in startIndex..size) {
            if (data[offset] == needle) {
                // found it!
                return offset
            }
        }

        -1
    }

    /* CASING */

    /**
     * Return a lower-case copy of this string
     */
    downcase: func -> This {
        res := clone()
        res downcase!()
        res
    }

    /**
     * Return an upper-case copy of this string
     */
    upcase: func -> This {
        res := clone()
        res upcase!()
        res
    }
    
    /**
     * Modify this string, transforming all characters
     * to lower-case.
     */
    downcase!: func@ {
        touch!()
        for (i in 0..size) {
            data[i] = data[i] downcase()
        }
    }

    /**
     * Modify this string, transforming all characters
     * to upper-case.
     */
    upcase!: func@ {
        touch!()
        for (i in 0..size) {
            data[i] = data[i] upcase()
        }
    }

    /**
     * Return an upper-case copy of this string
     * @deprecated Use upcase instead
     */
    toUpper: func -> This {
        upcase()
    }

    /**
     * Return a lower-case copy of this string
     * @deprecated Use downcase instead
     */
    toLower: func -> This {
        downcase()
    }

    /* SLICING */

    slice: func ~startLen (start, len: Int) -> This {
        buf := data + start
        (buf, len, -1) as This
    }

    slice: func ~range (range: Range) -> This {
        substring(range min, range max)
    }

    substring: func (start, end: Int) -> This {
        len := end - start
        buf := data + start
        (buf, len, -1) as This
    }

    /* CONCATENATION */

    append!: func@ (other: This) {
        oldsize := size
        resize!(size + other size)
        memcpy(data + oldsize, other data, other size + 1)
    }
    
    append: func (other: This) -> This {
        len := size + other size
        capa := len + 1
        buf := gc_malloc(capa) as Char*

        memcpy(buf, data, size)
        memcpy(buf + size, other data, other size)
        buf[len] = '\0'

        (buf, len, capa) as This
    }

    /* OUTPUT */

    println: func {
        stdout write(data, 0, size). write('\n')
    }

    /**
     * Re-allocate data with gc_malloc, so we can modify it.
     */
    realloc!: func@ {
        capacity = size + 1
        buf := gc_malloc(capacity)
        memcpy(buf, data, capacity)
        data = buf
    }

    resize!: func@ (newsize: Int) {
        touch!()
        capacity = newsize + 1
        gc_realloc(data, capacity)
        size = newsize
    }

    /* OPERATORS */

    operator [] (i: Int) -> Char {
        get(i)
    }

    operator@ []= (i: Int, c: Char) {
        set!(i, c)
    }

    operator + (other: This) -> This {
        append(other)
    }

    operator@ << (other: This) -> This {
        append!(other)
    }

    operator == (other: This) -> Bool {
        equals?(other)
    }

    operator != (other: This) -> Bool {
        !equals?(other)
    }

    /* UTILITIES */

    /**
     * Clone a string, with newly allocated memory
     */
    clone: func -> This {
        capa := size + 1
        buf := gc_malloc(capa)
        memcpy(buf, data, capa)
        (buf, size, capa) as This
    }

    /**
     * Freeze a string - any further modifications will
     * yield an exception.
     */
    freeze!: func@ {
        capacity = -2
    }

    /**
     * Prepare the string for mutation. If the string is frozen,
     * that won't work.
     */
    touch!: func@ {
        match capacity {
            case -1 => realloc!()
            case -2 => raise("can't modify a frozen String")
        }
    }

    /**
     * Check if a given index is in bounds or not
     */
    _checkIndex: func (i: Int) {
        if (i >= size || i < 0) {
            raise("can't access String of length #{size} at index #{i}")
        }
    }

}

Buf: cover from Str {

    new: static func -> Str {
        capa := 1024
        data := gc_malloc(capa)
        (data, capa - 1, capa) as Str
    }

}

extend Char {
    downcase: func -> This {
        toLower()
    }

    upcase: func -> This {
        toUpper()
    }
}

