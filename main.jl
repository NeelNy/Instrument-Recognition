using Gtk#: GtkBuilder, showall, signal_connect, GdkPixbuf, set_gtk_property!, GtkCssProvider
using Sound: record
using DelimitedFiles: writedlm

b = GtkBuilder(filename="GUI_schematic.glade") # grab config from glade

include("recorder.jl")
include("calibration.jl")

record(1) #julia will overflow portaudio on the first recording, so we need to record at least once before getting a useful recording

#calibrate the controls
#calibrate_controls()

# Main window modules
MainWindow = b["MainWindow"]
showall(MainWindow) # GTK refuses to work unless I show the window here

results_img = b["results_img"]
results_text = b["results_text"]
confidence_interval = b["confidence_interval"]

record_button = b["record_button"]
calibrate_button = b["calibrate_button"]
analyze_button = b["analyze_button"]
how_to_button = b["how_to_button"]

record_icon = b["record_icon"]

right_side_box = b["right_side_box"]
left_side_box = b["left_side_box"]

# Calibration Dialog modules
calibration_dialog = b["calibration_dialog"]
cancel_calib_dialog_button = b["cancel_calib_dialog_button"]
begin_calib_dialog_button = b["begin_calib_dialog_button"]

# How-to window modules
how_to_use_window = b["how_to_use_window"]
text_how_to = b["text_how_to"]
how_to_use_ok_button = b["how_to_use_ok_button"]

# Complete! Calibration Dialog
finish_calibration_dialog = b["finish_calibration_dialog"]
finish_calib_dialog_ok_button = b["finish_calib_dialog_ok_button"]

# Signals For Main window
# Record Button Change Symbol
signal_connect(record_button, "pressed") do widget
    if recording
        buf = GdkPixbuf(filename="media/off_button.png")
        set_gtk_property!(record_icon, :pixbuf, buf)
    else
        buf = GdkPixbuf(filename="media/on_button.png")
        set_gtk_property!(record_icon, :pixbuf, buf)
    end
end

# Record Button Call Record function
signal_connect(record_button, "released") do widget
    println("Record button clicked")
    if recording
        call_stop()
    else
        call_record()
    end
end

# Calibrate Button on Main window to subwindow
signal_connect(calibrate_button, "clicked") do widget
    println("Calibrate button clicked")
    showall(calibration_dialog)
end

# Helper for the analyze button
function update_display(instrument::String, Confidence)
    buf = GdkPixbuf(filename="media/$instrument.png")
    set_gtk_property!(results_img, :pixbuf, buf)
    set_gtk_property!(results_text, :label, "It's a $instrument !!")
    set_gtk_property!(confidence_interval, :label, "Confidence: $Confidence")
end

# Call Analyzing code and update display
signal_connect(analyze_button, "clicked") do widget
    println("Analyze button clicked")
    x, y = analyze_instrument()
    update_display(x, y)
end

# How-to button to subwindow
signal_connect(how_to_button, "clicked") do widget
    println("How-to button clicked")
    showall(how_to_use_window)
end

# Signal For How To Window
signal_connect(how_to_use_ok_button, "clicked") do widget
    println("Exit")
    hide(how_to_use_window)
end


# Signals for Calibration Window
signal_connect(cancel_calib_dialog_button, "clicked") do widget
    println("Exit")
    hide(calibration_dialog)
end

# Signal for Begin Calibration Button in subwindow on button release
signal_connect(begin_calib_dialog_button, "released") do widget
    println("Begin Calibration Button Pt 2")
    sleep(1)
    recording = record(15)
    writedlm("instrument/whiteNoiseIn.txt", recording[1])
    hide(calibration_dialog)
    showall(finish_calibration_dialog)
end

# Signal for Begin Calibration Button in subwindow on button press
signal_connect(begin_calib_dialog_button, "pressed") do widget
    println("Begin Calibration Button Pt 1")
    set_gtk_property!(calibration_dialog, "secondary-text", "Running Calibration...")
end

# Signal for Finish Calibration Dialog
signal_connect(finish_calib_dialog_ok_button, :clicked) do widget
    println("Exit")
    hide(finish_calibration_dialog)
end

# Applying CSS to all the things that need CSS
g = GtkCssProvider(filename="css.css")
push!(GAccessor.style_context(right_side_box), GtkStyleProvider(g), 600)
push!(GAccessor.style_context(left_side_box), GtkStyleProvider(g), 600)
push!(GAccessor.style_context(calibration_dialog), GtkStyleProvider(g), 600)
push!(GAccessor.style_context(finish_calibration_dialog), GtkStyleProvider(g), 600)
push!(GAccessor.style_context(how_to_use_window), GtkStyleProvider(g), 600)