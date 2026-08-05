#!/bin/bash

SESSION="ping-grid"

# اگر جلسه وجود ندارد، آن را ایجاد کن
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION -n "Network Monitor"
fi

# اگر فقط یک پنل داریم (اولین اجرا)، پنل‌ها را بساز
if [ "$(tmux list-panes -t $SESSION:0 | wc -l)" -eq 1 ]; then

    # --- تقسیم پنل‌ها به صورت 2x2 ---
    tmux split-window -h -t $SESSION:0          # ایجاد پنل راست (کل صفحه افقی به 2 قسمت)
    tmux split-window -v -t $SESSION:0.0        # تقسیم پنل چپ به دو قسمت عمودی
    tmux split-window -v -t $SESSION:0.2        # تقسیم پنل راست به دو قسمت عمودی

    # --- تنظیم نام و رنگ بوردر برای هر پنل ---
    # پنل 0: بالا-چپ — my_internet — آبی
    tmux select-pane -t $SESSION:0.0 -T "my_internet-4.2.2.4"
    tmux send-keys -t $SESSION:0.0 'ping 4.2.2.4' C-m
    tmux set-option -t $SESSION:0.0 pane-border-style "fg=blue,bg=default"

    # پنل 1: پایین-چپ — marava_ftth — سبز
    tmux select-pane -t $SESSION:0.1 -T "marava_ftth-ip_address"
    tmux send-keys -t $SESSION:0.1 'ping <ip_address>' C-m
    tmux set-option -t $SESSION:0.1 pane-border-style "fg=green,bg=default"

    # پنل 2: بالا-راست — marava_adsl — زرد
    tmux select-pane -t $SESSION:0.2 -T "marava_adsl-ip_address>"
    tmux send-keys -t $SESSION:0.2 'ping <ip_address>' C-m
    tmux set-option -t $SESSION:0.2 pane-border-style "fg=yellow,bg=default"

    # پنل 3: پایین-راست — website — قرمز
    tmux select-pane -t $SESSION:0.3 -T "website-domain"
    #tmux send-keys -t $SESSION:0.3 'ping <domain>' C-m
    tmux set-option -t $SESSION:0.3 pane-border-style "fg=red,bg=default"

    # --- تنظیم رنگ بوردر فعال (پنل انتخاب شده) ---
    tmux set-option -g pane-active-border-style "fg=brightwhite,bg=default"

fi

# اتصال به جلسه
tmux attach-session -t $SESSION
