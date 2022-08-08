using Sound

Sampling_rate = 48000
Time_in_secs = 20

soundsc(randn(Time_in_secs * Sampling_rate),Sampling_rate)
