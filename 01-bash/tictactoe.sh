#!/bin/bash
export TERM=xterm

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

check_win() {
    local wins=( # by indexes not field numbering
        "0 1 2"
        "3 4 5"
        "6 7 8"
        "0 3 6"
        "1 4 7"
        "2 5 8"
        "0 4 8"
        "2 4 6"
    )

    for combination in "${wins[@]}"; do
        read -r a b c <<< "$combination"
    
        local board_a="${board[$a]}"
        local board_b="${board[$b]}"
        local board_c="${board[$c]}"

        if [[  "$board_a" =~ ^[xo]$ ]] && # check if "x" or "o"
        [[  "$board_a" == "$board_b" ]] &&
        [[  "$board_a" == "$board_c" ]]; then

            clear
            print_title
            echo
            print_board
            echo
            echo "$board_a wins!"
            return 0
            
        fi
    done

    return 1
}

save_game() {
    echo "$i ${board[*]}" > tictactoe.save
    echo "Game has been saved!"
    sleep 1
}

load_game() {
    if [[ -f tictactoe.save ]]; then
        read -r saved_i saved_board < tictactoe.save
        i=$saved_i
        board=($saved_board)
        echo "Loaded saved game!"
        sleep 1  
    fi
}

main() {
    clear
    print_title
    read -p "Play against Computer? (y/n): " vs_pc

    i=0

    if [[ -f tictactoe.save ]]; then
        read -p  "Detected saved game! Continue? (y/n): " choice

        if [[ "$choice" =~ ^[yY]$ ]]; then
            load_game
        else
            i=0
        fi
    fi
    clear


    while [ $i -lt 9 ]; do
        clear
        print_title
        echo
        print_board
        echo
        
        # Switch sides logic
        if (( i % 2 == 0 )); then
            if [[ "$vs_pc" =~ ^[yY]$ ]]; then
                echo "X's turn! (Player)"
            else
                echo "X's turn!"
            fi
            piece="x"
            is_computer=false # X is always a player
        else

            if [[ "$vs_pc" =~ ^[yY]$ ]]; then
                is_computer=true
                echo "O's turn! (Computer)"
            else
                is_computer=false
                echo "O's turn!"
            fi
            piece="o"
        fi
        
        echo
        if [[ "$is_computer" == true ]]; then
            # Computer's logic
            echo "Computer is thinking..."
            sleep 1

            while true; do
                index=$(( RANDOM % 9))

                if [[ "${board[$index]}" =~ ^[1-9]$ ]]; then
                    board[$index]="$piece"
                    break    
                fi
            done
        else
            # Player's logic
            read -p "Enter a number (1-9) or \"s\" to save and exit:" number

            if [[ "$number" == "s" ]]; then
                save_game
                exit 0
            fi

            # Check if correct input
            if ! [[ "$number" =~ ^[1-9]$ ]]; then # =~ regex checks if number and in range ^[1-9]$
                echo "Invalid input! Enter number (1-9)."
                sleep 1
                continue
            fi

            # Check if field on board is free
            index=$((number - 1))
            if ! [[ "${board[$index]}" =~ ^[0-9]$ ]]; then
                echo "Field already taken!"
                sleep 1
                continue
            fi

            # Place piece
            board[$index]="$piece"
        fi

        # Check win
        if check_win; then
            exit 0
        fi

        ((i++))
    done

    # Handle tie situation
    clear
    print_title
    echo
    print_board
    echo
    echo "It's a Tie!"
}

main "$@"


