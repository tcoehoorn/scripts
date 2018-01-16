<?php

class Time {
    private $seconds;

    public function __construct($seconds) {
        $this->seconds = $seconds;
    }

    public function __toString() {
        $result = '';
        if ($this->calcHours() > 0) {
            $result .= $this->calcHours() . 'h ';
        }

        $result .= $this->calcExtraMinutes() . "m";

        return $result;
    }

    private function calcMinutes() {
        return $this->seconds / 60;
    }

    private function calcHours() {
        return floor($this->calcMinutes() / 60);
    }

    private function calcExtraMinutes() {
        return $this->calcMinutes() - ($this->calcHours() * 60);
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

    print $task . ': ' . $time . "\n";
}

$total_time = new Time($total_seconds);

print "\nTotal: " . $total_time . "\n";
