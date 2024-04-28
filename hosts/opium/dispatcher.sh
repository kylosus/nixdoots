#!/bin/sh

curl 'https://go.misaka.buzz/message?token=AAAAAA' -F 'title=Notification' -F "message=$(ip a)" -F 'priority=10'

ip a >> /ok

echo "$CONNECTIVITY_STATE" >> /ok

