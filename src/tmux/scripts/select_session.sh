################################################################################
#
# @brief 
#
# @param key: the key combination that identifies the command
#
# @param entries: fzf selected entries
# 
################################################################################
main()
{
	usage=$(cat <<-END
		1. (Enter) Select a session and attach to it with 
		2. (Ctrl+c) Type the name of a new session and create it
		3. (Ctrl+l) Select a session and create a link
		4. (Esc) Use a plain shell
	END
	)

	header=${usage}
	while :
	do
		while IFS= read -r query; do
			read -r key 
			read -r match
			if [[ "$key" == "ctrl-l" || "$key" == "enter" ]]; then
				if [[ -n $match ]]; then
					break 2
				else
					header=$(echo -e "${usage}\n\nWarning: You didn't select a session!")
				fi
			elif [[ "$key" == "ctrl-c" ]]; then
				tmux list-sessions -F "#{session_name}" | grep --fixed-strings --line-regexp "$query"
				# inserted query didn't match any session name
				if [[ $? -ne 0 && -n $query ]]; then
					break 2
				elif [[ -z $query ]]; then
					header=$(echo -e "${usage}\n\nWarning: Insert a session name")
				else
					header=$(echo -e "${usage}\n\nWarning: session ${query} already exists")
				fi
			elif [[ "$key" == "esc" ]]; then
				break 2
			fi

		done < <(tmux list-sessions -F "#{session_name}" \
			| fzf \
			--query "${query}" \
			--no-extended \
			--exact \
			--header="${header}" \
			--print-query \
			--expect="ctrl-l,ctrl-c,enter,esc" \
			--reverse
		)
	done

	if [[ "$key" == "ctrl-l" ]]; then
		exec tmux new-session -t "$match"
	elif [[ "$key" == "ctrl-c" ]]; then
		exec tmux new-session -s "$query"
	elif [[ "$key" == "enter" ]]; then
		exec tmux attach -t "$match"
	fi
}

command -v fzf > /dev/null
if [[ $? -eq 0 ]]; then
	main "$@"
fi
