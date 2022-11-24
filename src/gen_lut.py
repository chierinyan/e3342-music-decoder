#!/usr/bin/env python3

CODE_TABLE = {
    '0':   '00', '1':  '01', '2':  '02', '3':  '03', '4':  '04', '5':  '05', '6':  '06',
    '\n':  '10', '\t': '11', 'A':  '12', 'B':  '13', 'C':  '14', 'D':  '15', 'E':  '16', '+':   '17',
    '@':   '20', 'F':  '21', ':':  '22', 'G':  '23', 'H':  '24', 'I':  '25', 'J':  '26', '-':   '27',
    '#':   '30', 'K':  '31', 'L':  '32', ';':  '33', 'M':  '34', 'N':  '35', 'O':  '36', '*':   '37',
    '$':   '40', 'P':  '41', 'Q':  '42', 'R':  '43', '[':  '44', 'S':  '45', 'T':  '46', '/':   '47',
    '%':   '50', 'U':  '51', 'V':  '52', 'W':  '53', 'X':  '54', ']':  '55', 'Y':  '56', '^':   '57',
    '&':   '60', 'Z':  '61', '!':  '62', ',':  '63', '?':  '64', ' ':  '65', '_':  '66', '=':   '67',
                 '7':  '71', '8':  '72', '9':  '73', '<':  '74', '>':  '75', '(':  '76', ')':   '77'
}

if __name__ == '__main__':
    lut = []
    for key in CODE_TABLE:
        lut.append('when o"{}" => dout <= "{:08b}";\n'.format(CODE_TABLE[key], ord(key)))
    with open('lut.txt', 'w') as lutf:
        lutf.writelines(lut)
