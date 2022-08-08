#=
# Utility code to record buffered audio up to 10 seconds for the record functionality of our program.
# This code has been adapted from the examples found within
# the Sound.jl Library, written by Professor Fessler
# link: https://github.com/JeffFessler/Sound.jl/blob/main/examples/gtk-record.jl
=#
using Gtk: set_gtk_property!
using PortAudio: PortAudioStream
using DelimitedFiles: writedlm

# initialize global variables that are used throughout
const global S = 48000 # sampling rate (samples/second)
global const N = 1200 # buffer length
global const maxtime = 10 # maximum recording time 10 seconds
global recording = false # flag
global nsample = 0 # count number of samples recorded
global song = nothing # initialize "song"


# callbacks

# callback function for "record" button
# The @async below is important so that the Stop button can work!
function call_record()
    global N
    in_stream = PortAudioStream(1, 0) # default input device
    buf = read(in_stream, N) # warm-up
    global recording = true
    global song = zeros(Float32, maxtime * S)
    @async record_loop!(in_stream, buf)
    nothing
end


# callback function for 2nd press of record button, or when record loop reaches max time
function call_stop()
    global recording = false
    global nsample
    sleep(0.1) # ensure the async record loop finished
    global song = song[1:nsample] # truncate song to the recorded duration
    nsample = 0
    writedlm("instrument/inst_in.txt", song)
end


function record_loop!(in_stream, buf)
    global maxtime
    global S
    global N
    global recording
    global song
    global nsample
    Niter = floor(Int, maxtime * S / N)
    for iter in 1:Niter
        if !recording
            break
        end
        read!(in_stream, buf)
        song[(iter-1)*N.+(1:N)] = buf # save buffer to song
        nsample += N
    end
    print(nsample)
    if nsample == maxtime * S # sort of a hack to get it to stop and set the GUI without using a callback, there really shouldn't be GUI code in here
        buf = GdkPixbuf(filename="media/off_button.png")
        set_gtk_property!(record_icon, :pixbuf, buf)
        print("Max time reached")
        call_stop()
    end
    nothing
end
