TITLE Pascal's Triangle Generator     (PascalTriangle.asm)

; Author: Samuel Baird
; Last Modified: 11/05/2025
; OSU email address: bairsamu@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 4                Due Date: 11/16/2025
; Description: This program prompts the user to enter a number of rows (1-20)
;              for Pascal's Triangle, validates the input, and displays that many
;              rows of Pascal's Triangle in an isosceles (centered) format.
;              Uses the binomial coefficient "n choose k" formula to calculate
;              each element of the triangle.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: MAX_ROWS
; Description: Maximum number of rows allowed for Pascal's Triangle
; ---------------------------------------------------------------------------------
MAX_ROWS = 20

; ---------------------------------------------------------------------------------
; Name: MIN_ROWS
; Description: Minimum number of rows allowed for Pascal's Triangle
; ---------------------------------------------------------------------------------
MIN_ROWS = 1

; ---------------------------------------------------------------------------------
; Data Segment
; ---------------------------------------------------------------------------------
.data
    ; Introduction strings
    programTitle    BYTE    "Pascal's Triangle Generator - Programmed by Samuel Baird", 0
    intro1          BYTE    "This program will print up to 20 rows of Pascal's Triangle, per your specification!", 0
    ec1             BYTE    "**EC: This program aligns the triangle to appear isosceles (symmetric).", 0
    ec2             BYTE    "**EC: This program prints up to 20 rows of Pascal's Triangle.", 0
    
    ; User input prompts
    prompt1         BYTE    "Enter total number of rows to print [", 0
    prompt2         BYTE    "...", 0
    prompt3         BYTE    "]: ", 0
    errorMsg        BYTE    "Invalid input! Please enter a number in the specified range.", 0
    
    ; Farewell message
    farewellMsg     BYTE    "Thanks for using Pascal's Triangle Generator! Goodbye!", 0
    
    ; Global variables (allowed for this assignment)
    numRows         DWORD   ?       ; Number of rows to display
    currentRow      DWORD   ?       ; Current row being printed
    currentCol      DWORD   ?       ; Current column in row
    nValue          DWORD   ?       ; n value for nChooseK
    kValue          DWORD   ?       ; k value for nChooseK
    result          DWORD   ?       ; Result of nChooseK calculation
    spaces          DWORD   ?       ; Number of spaces for alignment

; ---------------------------------------------------------------------------------
; Code Segment
; ---------------------------------------------------------------------------------
.code
main PROC
    call    introduction
    call    getUserInput
    call    printPascalTriangle
    call    farewell
    
    Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Description: Displays the program title, programmer name, and description.
;              Also displays extra credit descriptions.
;
; Preconditions: None
;
; Postconditions: Introduction text displayed to console
;
; Receives: None
;
; Returns: None
; ---------------------------------------------------------------------------------
introduction PROC
    ; Display program title
    mov     edx, OFFSET programTitle
    call    WriteString
    call    CrLf
    
    ; Display program description
    mov     edx, OFFSET intro1
    call    WriteString
    call    CrLf
    
    ; Display extra credit 1
    mov     edx, OFFSET ec1
    call    WriteString
    call    CrLf
    
    ; Display extra credit 2
    mov     edx, OFFSET ec2
    call    WriteString
    call    CrLf
    call    CrLf
    
    ret
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserInput
;
; Description: Prompts user for number of rows and validates input is within
;              the range [MIN_ROWS...MAX_ROWS]. Re-prompts if invalid.
;
; Preconditions: MIN_ROWS and MAX_ROWS constants defined
;
; Postconditions: numRows contains valid user input
;
; Receives: None (uses global variables)
;
; Returns: numRows = validated user input
; ---------------------------------------------------------------------------------
getUserInput PROC
GetInput:
    ; Display prompt
    mov     edx, OFFSET prompt1
    call    WriteString
    mov     eax, MIN_ROWS
    call    WriteDec
    mov     edx, OFFSET prompt2
    call    WriteString
    mov     eax, MAX_ROWS
    call    WriteDec
    mov     edx, OFFSET prompt3
    call    WriteString
    
    ; Get user input
    call    ReadInt
    mov     numRows, eax
    
    ; Validate input (check if in range [MIN_ROWS...MAX_ROWS])
    cmp     eax, MIN_ROWS
    jl      InvalidInput
    cmp     eax, MAX_ROWS
    jg      InvalidInput
    jmp     ValidInput
    
InvalidInput:
    ; Display error message and re-prompt
    mov     edx, OFFSET errorMsg
    call    WriteString
    call    CrLf
    jmp     GetInput
    
ValidInput:
    call    CrLf
    ret
getUserInput ENDP

; ---------------------------------------------------------------------------------
; Name: printPascalTriangle
;
; Description: Prints the specified number of rows of Pascal's Triangle.
;              Centers each row for isosceles appearance.
;
; Preconditions: numRows contains valid number of rows to print
;
; Postconditions: Pascal's Triangle displayed to console
;
; Receives: numRows = number of rows to print (global variable)
;
; Returns: None
; ---------------------------------------------------------------------------------
printPascalTriangle PROC
    mov     ecx, numRows        ; Loop counter = number of rows
    mov     currentRow, 0       ; Start with row 0
    
PrintRowLoop:
    push    ecx                 ; Save loop counter
    
    ; Calculate leading spaces for centering
    ; spaces = (maxRows - currentRow - 1) * 4
    mov     eax, numRows
    dec     eax
    sub     eax, currentRow
    mov     ebx, 4
    mul     ebx
    mov     spaces, eax
    
    ; Print leading spaces
    mov     ecx, spaces
    cmp     ecx, 0
    je      SkipSpaces
PrintSpaces:
    mov     al, ' '
    call    WriteChar
    loop    PrintSpaces
    
SkipSpaces:
    ; Print the row
    call    printPascalRow
    call    CrLf
    
    ; Move to next row
    inc     currentRow
    
    pop     ecx                 ; Restore loop counter
    loop    PrintRowLoop
    
    call    CrLf
    ret
printPascalTriangle ENDP

; ---------------------------------------------------------------------------------
; Name: printPascalRow
;
; Description: Prints all elements in a single row of Pascal's Triangle.
;              Uses nChooseK to calculate each element.
;
; Preconditions: currentRow contains the row index to print
;
; Postconditions: One row of Pascal's Triangle printed
;
; Receives: currentRow = index of row to print (global variable)
;
; Returns: None
; ---------------------------------------------------------------------------------
printPascalRow PROC
    mov     currentCol, 0       ; Start with column 0
    mov     eax, currentRow
    inc     eax
    mov     ecx, eax            ; Loop counter = currentRow + 1
    
PrintColLoop:
    push    ecx                 ; Save loop counter
    
    ; Set up parameters for nChooseK
    mov     eax, currentRow
    mov     nValue, eax
    mov     eax, currentCol
    mov     kValue, eax
    
    ; Calculate nChooseK
    call    nChooseK
    
    ; Print result with width of 7 for alignment
    mov     eax, result
    call    WriteDec
    
    ; Print spacing between numbers (8 spaces total for alignment)
    mov     al, ' '
    call    WriteChar
    call    WriteChar
    call    WriteChar
    call    WriteChar
    call    WriteChar
    call    WriteChar
    call    WriteChar
    call    WriteChar
    
    ; Move to next column
    inc     currentCol
    
    pop     ecx                 ; Restore loop counter
    loop    PrintColLoop
    
    ret
printPascalRow ENDP

; ---------------------------------------------------------------------------------
; Name: nChooseK
;
; Description: Calculates the binomial coefficient "n choose k" using an
;              optimized multiplicative formula with careful overflow prevention.
;              Uses the formula C(n,k) = n!/(k!(n-k)!) computed as:
;              C(n,k) = (n-k+1)/1 * (n-k+2)/2 * (n-k+3)/3 * ... * n/k
;              Each step multiplies by numerator then divides by denominator.
;
; Preconditions: nValue and kValue contain valid values where 0 <= k <= n <= 20
;
; Postconditions: result contains the calculated binomial coefficient
;
; Receives: nValue = n value (global variable)
;           kValue = k value (global variable)
;
; Returns: result = nCk (global variable)
; ---------------------------------------------------------------------------------
nChooseK PROC
    pushad                      ; Save all registers
    
    ; Check special cases: k=0 or k=n
    mov     eax, kValue
    cmp     eax, 0
    je      SetResultOne        ; C(n,0) = 1
    
    mov     ebx, nValue
    cmp     eax, ebx
    je      SetResultOne        ; C(n,n) = 1
    
    ; Use symmetry property: C(n,k) = C(n,n-k)
    ; Always calculate with smaller k to minimize iterations and overflow risk
    mov     eax, nValue
    sub     eax, kValue         ; eax = n - k
    cmp     kValue, eax
    jle     NoSwap
    mov     kValue, eax         ; Use (n-k) if it's smaller
    
NoSwap:
    ; Initialize result = 1
    mov     edi, 1              ; edi holds our accumulating result
    
    ; Loop through i = 1 to k
    ; In each iteration: result = result * (n - k + i) / i
    mov     esi, 1              ; esi = loop counter i (1 to k)
    
CalcLoop:
    mov     eax, kValue
    cmp     esi, eax
    jg      SetResult           ; if i > k, we're done
    
    ; Calculate numerator factor: (n - k + i)
    mov     eax, nValue
    sub     eax, kValue
    add     eax, esi            ; eax = n - k + i
    
    ; Multiply: result = result * (n - k + i)
    mul     edi                 ; edx:eax = edi * (n - k + i)
    
    ; Divide: result = result / i
    mov     ebx, esi            ; ebx = i
    div     ebx                 ; eax = (result * (n - k + i)) / i
    mov     edi, eax            ; Store result back
    
    inc     esi                 ; i++
    jmp     CalcLoop
    
SetResultOne:
    mov     edi, 1
    
SetResult:
    mov     result, edi
    popad                       ; Restore all registers
    ret
    
nChooseK ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Description: Displays a farewell message to the user.
;
; Preconditions: None
;
; Postconditions: Farewell message displayed
;
; Receives: None
;
; Returns: None
; ---------------------------------------------------------------------------------
farewell PROC
    mov     edx, OFFSET farewellMsg
    call    WriteString
    call    CrLf
    
    ret
farewell ENDP

END main
