---
layout: post
title:  "Microcontrollers - Hardware Design"
post-title:  "Microcontrollers - Hardware Design"
date:   2021-11-13 16:52:46 -0500
permalink: /tutorials/microcontrollers_tutorial_1
permalink_name: /microcontrollers_tutorial_1
category: tutorials
description: "Microcontroller design series - from building a board to running a RTOS"

categories: tutorial microcontrollers hardware
---

---

This is part 1 of a 3 part tutorial series on microcontrollers. This tutorial is going to cover hardware design,
programming your micro, and lastly how to run an RTOS on your micro.

Part 1 - Hardware Design - Things You'll Learn
* What is a microcontroller
* How to pick a microcontroller
* How to design a board around it
* How to order your board and have it assembled

I'll be using KiCad for board design due to the fact it's free so anyone can follow along. 

It's a good starter tool if you only need to spin the occasional board. Development for this series will be done in Linux (Ubuntu 20.04 LTS).

Requirements
```shell
sudo apt update
sudo apt upgrade
sudo apt install kicad
```
You'll also need to install STM32CubeMX if you want to follow me exactly. Download the Debian package from [here](https://www.st.com/en/development-tools/stm32cubemx.html) and run
```shell
sudo apt install {path to your download}/{download name}
```

---
# What is a Microcontroller
This section on its own could be multiple write-ups, so I'll keep it simple. A microcontroller is a chip that contains a processor, memory, and onboard peripherals all within a single chip.

The main differences between a microcontroller and a microprocessor is that microcontroller drains less power on average, and it does not have a memory management unit.

This means that you only work with real memory on a microcontroller rather than [virtual memory](https://youtu.be/Aw0YAUdQp1c) like you would by running a C program on your desktop.

Occasionally you'll hear the term SoC as well, which stands for system on a chip. This is more or less a marketing term which means a microcontroller with very specific peripherals on it that can accomplish certain purposes. This is a marketing term more or less, and has no straightforward definition.

Some SoCs have configurable digital logic on them (like with an FPGA) but overall just look at the datasheet to see what the chip actually is.

---
# How to pick a Microcontroller
There are 10 trillion parts to chose from (and about 7 of them are in stock at the moment). This section is going to introduce you to parametric search, basic specs about microcontrollers, and why you might pick a certain processor over another.

*Driving Factors*
---
* Performance (How fast can it process)
* Peripherals
* Power Draw (Battery constrained environments need low power draw)
* Availability (Welcome to the chip-pocalypse)
* Temperature Range (Does this need to run inside a car?)
* Cost (Duh)

*Performance*
---
Performance is effectively a measure of how much math a processor can do in a given amount of time. This is very difficult to get an accurate read on because certain processors do certain things better, and you'll never have time to go all the way down the rabbit hole.

The end all be all I'll leave you with is that most modern ARM microcontrollers can handle what you need and do it cheaply. If don't need much performance there's the ATTiny series or the STM8 series I know of off the top of my head.

Clock speed effects performance, but it's not a 1 to 1 comparison because certain microcontrollers take multiple clock cycles to execute an instruction(like old PICs) while others execute most instructions in a single cycle(like AVR chips).

*Peripherals*
---
Peripherals are the other bits and pieces of hardware on the chip that do what you need. Read about them in [this tutorial](https://patrickcpe.github.io/tutorials/peripheral_basics.html).

Sometimes you're going to need 3 SPI peripherals and 2 UART lines, or if you're working on an industrial system you will probably need a CAN peripheral. This is usually the first requirement you sort by when designing a particular system.

*Power Draw*
---
Every chip markets itself as a low power battery saving miracle of God. Truth be told, the front page of the datasheet is written by marketing folks. 

If you have a chip that only needs to process on occasion in a power constrained environment check what the different sleep modes drain in the datasheet. If the mode you need (such as sleep but maintain memory) is within your power budget then that chip works.

*Availability*
---
Welcome to 2021, the year just in time manufacturing came to a halt. Chip foundries can't keep up with demand, shipping is a mess, and chips that used to cost $2 now cost $40.

If you're making a product that is meant to be more than a single run make sure you chose a chip that is still in the active stage of its lifecycle, is in stock, and restocks at a respectable rate.

Use your jellybean parts because they'll always be around. If you have a reason you need something special you better make sure you'll be able to procure it when you need it.

*Temperature Range*
---
Pretty simple here, pick the package that works in your temp range. If you're working in the artic you'll likely need the military grade package rather than the consumer grade, etc.

*Cost*
---
You always need to compromise between costs and the other factors. I go by the idea of it's not worth saving pennies when it will cost you dimes in the long run. Pick the part that solves the problem and saves you the most time. It doesn't matter if it's a tad more expensive.

If you're making a million boards you know how to cut costs and design for manufacturing, but chances are that isn't the person reading this.

---
# Let's pick our processor

I'm going with something from the STM32 line of chips because they're
* Cheap
* Powerful
* Have good documentation
* Have a good software environment

I'm going to pick from the selection that [JLCPCB](https://jlcpcb.com/parts/componentSearch?isFirstLevel=true&firstName=EMBEDDED%20PROCESSORS%20%26%20CONTROLLERS) has because they do board design and assembly for cheap.
Select ST Microelectronics and check the In-Stock box, I recommend you sort by stock as well. Here are my results:
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/search_result_jlc.png" alt="JLC PCB Search Results" width="700">

[ST](https://www.st.com/en/microcontrollers-microprocessors/stm32-32-bit-arm-cortex-mcus.html) tells you the main purpose of the different versions on this page.

For now lets go for the [STM32L071RBT6](https://www.st.com/content/ccc/resource/technical/document/datasheet/b5/24/80/11/51/59/47/f7/DM00141136.pdf/files/DM00141136.pdf/jcr:content/translations/en.DM00141136.pdf). There is plenty of stock, and it will let us practice low power best practices. 


---
# Designing a Board
We chose our processor. We're going to make a simple breakout board for it.

Run KiCad
File -> New Project -> Name and Save

Double-Click the Schematic and let's open it up.
shift + A -> Click -> Select our Part (STM32l071RBTx) -> Left click to add it to the schematic.

---

This chip has 5 voltage pins that we're going to need to decouple(You can filter the analog for better Mixed Signal performance, but we'll keep it simple here). This is vital for chip performance.

Let's use some standard 0.1 uF 0603 Ceramic Caps from JLCPCB. It looks like CC0603KRX7R9BB104 will work.

Place 5 C_Smalls onto the schematic.

---

Next up we're going to need a USB header and power regulation for it.

We'll use 10118194-0001LF for a USB header, and XC6206P332MR for the linear regulator. This chip can convert our +5V to +3.3V for our chip.

Add USB_B to the schematic and xC6206PxxxNR as well. Add 2 C_Smalls as well for the voltage regulator. We'll be using CL10A105KB8NNNC the decoupling caps.

---

We're going to need to add a jumper for the Boot Pin. This pin determines whether your board will run the bootloader or run the burnt program.

Let's add a r_small and a SolderJumper_2_Open to the schematic.

We'll use 0603WAF1002T5E for the pull down-resistor.

---

The final thing we're going to need to add is a crystal.
If we look at our oscillator inputs and the clock tree in STM32Cube we can see that an 8 MHz crystal will work alongside our PLL to max out the clock speed to 32 MHz.

<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/cube_chip.png" alt="STM32Cube Chip View" width="700">

<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/cube_clock_tree.png" alt="STM32Cube Clock tree" width="700">

Let's use the X50328MSB2GI, and we're going to need to add loading capacitors. Go into the [datasheet](https://datasheet.lcsc.com/lcsc/2103291135_Yangxing-Tech-X50328MSB2GI_C115962.pdf) and find the load_capacitance.

The value you'll use for the load capacitors is CL = 2 (Cload - Cstray) where Cstray is usually between 3 and 5 pF.

So for us, it will be CL = 2 (20 pF - 4 pF) = ~32 pF = 30 pF nominal

With that in mind let's add 2 more c_smalls to the schematic, and a crystal_small. We'll use this for the capacitors CL10C300JB8NNNC.

---

The only thing I still like to do is add 2 LEDs onto the board, one to show that the system is powered, and another to that you can blink via the microcontroller.

Let's add 2 LED_Smalls and 2 more R_Smalls for the current limiting resistors. Let's use this 19-213/Y2C-CQ2R2L/3T(CY) for an LED, and we'll run at a fairly low current, so we'll use 0603WAF1001T5E for resistors.

---

We also need to add some 0.1" headers for our pin breakouts. Let's use 12251120CNG0S115005.

Add 2 Conn_01x20's to your schematic

---

Your schematic should look something like this
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/schematic_pre.png" alt="Schematic Components Placed" width="700">

Let's lay out the schematic properly now that we have the parts, You'll notice I skipped quite a few steps here.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/schematic_post.png" alt="Schematic Components Placed" width="700">

The order of events went as followed
* Label components with proper values
* Sort by functional block and wire up schematic
* Wire headers according to the physical pinout of the chip
* Organize sub-circuits and add labels and notes throughout
* Box of the sub-circuits

Next up we need to annotate the schematic in KiCad 
(Annotate Schematic Symbols -> Annotate)

After this we're going to run electrical rule check. If you looked closely before you would see a ton of mistakes in the schematic. ERC catches these a lot of the time and will warn you. Fix any mistakes you find, and excuse any that are acceptable.

After the fixes you'll have this.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/schematic_post_2.png" alt="Schematic Components Placed" width="700">
(You could have excused the unused pins, that's up to personal taste.)

The final step is to go through and assign footprints. After assigning, be sure to hit Apply, Save Schematic and Continue. You should have something like this.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/footprints_assigned.png" alt="Footprints Assigned" width="700">

Click PCB New in the toolbar and let's move on to layout.

---

# Creating Your PCB
---
When you open the PCB you'll have nothing there. Hit update PCB from schematic to drop your components in.

Let's click on board setup and get everything set for design. We're opting for a 2-layer board with so the default Two layers, parts on front and back setting will do.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/layer_rules.png" alt="Layer Rules" width="700">

---

For the design rules I'll be using [JLCPCB](https://jlcpcb.com/capabilities/Capabilities) so let's use their rules. These rules are vendor dependent so check their site.

You should have something like this when it's all said and done.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/clearance_rules.png" alt="Clearance Rules" width="700">
Just remember, KiCad doesn't support via to via distance so don't go below the manufacturer tolerance there (in my case .254 mm)

---

Next up let's sketch out our board dimensions. Go to the cutout layer and draw your board outline using Add Graphic Line. Pick something a bit bigger than is really necessary if this is your first board.

You should have something like this sketched out.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/board_outline.png" alt="Board Outline" width="700">

And after placing your parts you should have something like this. You should place your components in this order, your goal is to make every trace as short as possible.

1. Connectors
2. Microcontroller
3. Clock (Make sure the traces are as short as you can get)
4. Decoupling Caps (Look at that! We missed a decoupling cap for VDDIO, let's go back, add one more and then push it forward to the PCB)
5. Power Regulation
6. Misc. (LEDs, Jumpers, etc.)

Here's what I had after all of that
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/pcb_components_placed.png" alt="Components Placed" width="700">

Add a Ground Plane to the second layer to provide a low impedance return path for all of your signals.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/pcb_ground.png" alt="Ground Placed" width="700">

After this is done it's time to route everything. Remember to route in order of criticality (Clock, Decoupling, Power, Misc.)

Here's what I got. It's far from perfect, but this is a hobby development board. This isn't going in the next Rover.

<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/board_routed.png" alt="Board Routed" width="700">

Look at that image, notice anything missing? The power traces are still super thin! Let's make those bigger where we can.

Here's how it looks now
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/board_routed_thicker.png" alt="Board Routed Thicker Traces" width="700">

You'll notice that there are a bunch of little arrows on the PCB. These are from running Design Rule Check. I've looked through these errors myself and none of them are real errors. They just have to do with your design rules. (I left my design rules somewhat imprecise)

Once you're done with DRC lets set up our silkscreen layer. This is where you place the reference designators for each component on the board.

Here's what I got
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/board_ref_des.png" alt="Board Ref Designators" width="700">

Congrats, you laid out the board. Now comes the annoying part. Follow [this](https://support.jlcpcb.com/article/84-how-to-generate-the-bom-and-centroid-file-from-kicad)  tutorial on how to add JLCPCB footprints and part numbers if you're using them.

The Part #'s I gave you throughout this were the manufacturer number. If you're using JLC make sure you use their respective LCSC part number. You can either follow that tutorial or just edit the spreadsheet manually (What I tend to opt for)

Here's my BOM CSV file after I finished editing it (use Excel for that)
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/bom_csv.png" alt="BOM CSV File" width="700">

Here's what my Pick and Place CSV looked like after adjusting it
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/pp_csv.png" alt="Pick and Place CSV File" width="700">

After that we need to generate gerber files and drill files.

File -> Plot -> Generate Drill Files (Pick Directory for output) -> Drill Files Done
File -> Plot -> Plot (Pick Directory for output) -> Gerber Files Done

Defaults are fine for both. Once that is done, Zip the Gerber's and drill files, and it's time to order.


# Ordering Your Board
On JLC click instant quote and upload your board files.

Here's what I chose for settings. You'll notice I chose a location for the label they add. This was something I did after the fact so the serial number they print won't be seen (I hid it under the MCU)
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/jlc_choices.png" alt="JLCPCB Choices" width="700">

You'll need to check off the assembly box as well if you'd like them to assemble it. Let them place the tooling holes themselves. Once you accept the terms you'll be transferred to a page where you upload the Pick and Place and BOM files. Go ahead and do that.

There were some discrepancies in my BOM file I had to change (thanks to conflicting docs on their end) but eventually you get this screen
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/parts_uncomfirmed.png" alt="Parts Uncomfirmed" width="700">

Confirm everything is correct and move on. I had to fiddle with the component orientations somewhat on my end to get it to work. This is the end result.
<img src="/assets/images/posts/tutorials/microcontrollers_tutorial_1/jlc_placement.png" alt="JLC Placement" width="700">

And just like that we have 5 boards order and assembled (minus the 0.1" headers) for less than $50 (and that's with the 3-day shipping).

---
# Wrapping Up
I hope this helps you when it comes to designing boards and getting started with this sort of thing. I know this was a bit long-winded, but best of luck with your board design :)
