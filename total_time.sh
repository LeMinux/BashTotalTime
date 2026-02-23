function print_times {

    declare -i hours="$1"
    declare -i minutes="$2"
    declare -i seconds="$3"

    #set to proper time
    minutes=$((minutes + seconds / 60))
    seconds=$((seconds % 60))
    hours=$((hours + minutes / 60))
    minutes=$((minutes % 60))

    if [[ $hours -gt 0 ]];then
        echo "$hours hours $minutes minutes $seconds seconds"
    else
        echo "$minutes minutes $seconds seconds"
    fi
}

function main {
    if [[ $# -ne 1 ]]; then
        echo "Need to specify one directory path"
        exit 1
    fi

    dir=$1
    if [[ ! -d "$dir" ]]; then
        echo "Path is not a directory"
        exit 1
    fi

    declare -i total_miss=0
    declare -i hours=0
    declare -i minutes=0
    declare -i seconds=0
    declare -i total_songs=0

    while read -r song; do
        echo "Found $song"
        total_songs+=1
        local duration=$(exiftool -Duration -s3 "$song" | sed 's/ *(approx)//I')
        if [[ -z "$duration" ]]; then
            total_miss+=1
            echo "$song has no duration tag $duration" >&2
        else
            declare -i split_count=$(echo "$duration" | tr -cd ':' | wc -c)
            #reason for the 10# is because bash interprets leading zero numbers as octal
            if [[ split_count -ge 3 ]]; then
                echo "$song has misformatted duration $duration" >&2
                total_miss += 1
            elif [[ split_count -eq 2 ]]; then
                hours=$((hours + 10#$(echo "$duration" | awk -F: '{print $1}')))
                minutes=$((minutes + 10#$(echo "$duration" | awk -F: '{print $2}')))
                seconds=$((seconds + 10#$(echo "$duration" | awk -F: '{print $3}')))
            elif [[ split_count -eq 1 ]]; then
                minutes=$((minutes + 10#$(echo "$duration" | awk -F: '{print $1}')))
                seconds=$((seconds + 10#$(echo "$duration" | awk -F: '{print $2}')))
            else
                seconds=$((seconds + 10#$(echo "$duration" | awk -F. '{print $1}')))
            fi
        fi
    done < <(find "$dir" -type f -name "*.mp[3,4]")
    #using proccess subsitution so that the while still updates the variables
    #and the variables remain changed rather than within a subshell

    echo "Calculation for $dir"
    echo "Checked $total_songs songs"
    echo "$total_miss errors"
    print_times "$hours" "$minutes" "$seconds"
}

main "$@"
