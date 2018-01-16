<?php

class Time {
    private $seconds;

    public function __construct($seconds) {
        $this->seconds = $seconds;
    }

    public function calcHours() {
        $minutes = $this->seconds / 60;
        return floor($minutes / 60);
    }

    public function calcExtraMinutes() {
        $minutes = $this->seconds / 60;
        return $minutes - ($this->calcHours() * 60);
    }

    public function toString() {
        $result = '';
        if ($this->calcHours() > 0) {
            $result .= $this->calcHours() . 'h ';
        }

        $result .= $this->calcExtraMinutes() . "m\n";

        return $result;
    }
}

$file_path = '/home/trevor/tmp/time.csv';
$time_index = 0;
$task_index = 1;
$prev_time = NULL;
$time_sums = [];
$total_seconds = 0;

$handle = fopen($file_path, 'r');

while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
    $cur_time = strtotime($data[$time_index]);
    $task = $data[$task_index];

    if (!empty($task) && $prev_time != NULL) {
        $time_diff = $cur_time - $prev_time;
        if (isset($time_sums[$task])) {
            $time_sums[$task] += $time_diff;
        } else {
            $time_sums[$task] = $time_diff;
        }

    }

    $prev_time = $cur_time;
}

fclose($handle);

foreach ($time_sums as $task => $seconds) {
    $time = new Time($seconds);
    $total_seconds += $seconds;


    print $task . ': ' . $time->toString();
}

$total_time = new Time($total_seconds);

print "\nTotal: " . $total_time->toString();
