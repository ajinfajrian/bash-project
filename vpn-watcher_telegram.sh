#!/bin/bash

# Telegram bot token and chat details
tg_token="telegram_bot"
tg_chat_id="telegram_group_id"
tg_chat_type="HTML"  # Options: Markdown / HTML
tg_thread_id=3       # Message thread ID for sending in a thread

# Save the initial output
initial_file="/tmp/vpn_users_initial.txt"
/usr/local/softether/vpncmd localhost:443 /server /password:<softether_password> /adminhub:VPN /cmd SessionList | grep 'User Name' | awk '{print $3}' | tr -d '|' | grep -v 'SecureNAT' > "$initial_file"

# Monitor for changes
while true; do
    latest_file="/tmp/vpn_users_latest.txt"
    /usr/local/softether/vpncmd localhost:443 /server /password:<softether_password> /adminhub:VPN /cmd SessionList | grep 'User Name' | awk '{print $3}' | tr -d '|' | grep -v 'SecureNAT' > "$latest_file"

    # Check for differences between the old and new file
    if ! diff "$initial_file" "$latest_file" > /dev/null; then
        echo "Change detected! Sending updated VPN connection list to Telegram."

        # Prepare the message, escaping any special characters
        tg_message=$(printf "SSTP Connection List:\n%s" "$(cat "$latest_file" | sed 's/"/\\"/g')")

        # Ensure message is not empty before sending
        if [ -n "$tg_message" ]; then
            echo "SSTP Connection List:"
            cat "$latest_file"

            # Send the message to Telegram
            curl -s -X POST "https://api.telegram.org/bot$tg_token/sendMessage" \
              -H "accept: application/json" \
              -H "content-type: application/json" \
              -H "User-Agent: Mozilla/5.0 (Linux; Android 5.0; SAMSUNG-SM-N900A Build/LRX21V)" \
              -d '{
                    "chat_id": "'$tg_chat_id'",
                    "text": "'"$tg_message"'",
                    "parse_mode": "'$tg_chat_type'",
                    "message_thread_id": '$tg_thread_id'
                  }'
        else
            echo "No message to send, the message is empty."
        fi

        # Update the initial file with the latest output
        cp "$latest_file" "$initial_file"
    fi

    sleep 6 # Check every 6 seconds
done
