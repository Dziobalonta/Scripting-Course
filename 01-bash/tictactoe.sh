#!/bin/bash

piece=x
board=("1" "2" "3"
    "4" "5" "6"
    "7" "8" "9"
)

print_board() {
    echo "${board[0]} | ${board[1]} | ${board[2]}"
    echo "--+---+--"
    echo "${board[3]} | ${board[4]} | ${board[5]}"
    echo "--+---+--"
    echo "${board[6]} | ${board[7]} | ${board[8]}"
}

print_title() {
    echo "================"
    echo "Tic-Tac-Toe Game"
    echo "================"
}

main() {
    i=0
    while [ $i -lt 9 ]
    do
        clear
        print_title
        echo
        print_board
        echo
        
        # Switch sides logic
        if (( i % 2 == 0 )); then
            echo "X's turn!"
            piece="x"
        else
            echo "O's turn!"
            piece="o"
        fi
        

        read -p "Enter a number (1-9):" number
        echo

        # Check if correct input
        if [ $number -ge 1 ] && [ $number -le 9 ]; then
            echo "Input: $number is valid."
        else 
            echo "Input: $number is invalid."
            continue # Restart loop
        fi

        # Place a piece on a board
        for j in "${!board[@]}" # !-by indexes
        do
            if [ "${board[$j]}" -eq "$number" ]; then
                board[$j]="$piece"
            fi
            echo "${board[$j]}"
        done
        
        ((i++))

    done


}

main "$@"


