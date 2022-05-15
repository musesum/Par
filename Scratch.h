
√ {
    sky {  // visual music program
        main {  // main controls
            frame (0)  // frame counter
            fps (1..60 = 60)  // frames per second
            run (1)  // currently running
        }
        pipeline {  // default metal pipeline at atartup
            draws "draw"  // drawing layer
            ave "compute"  // compute layer
            color "color"  // colorizing layer
            render "render"  // render layer al
        }
        dock {  // list of panel items to put in dock
            camera fade ave (1) melt tunl zha slide fred brush color scroll tile speed record }
        color {  // false color mapping palette
            pal0 "roygbik"  // palette 0: (r)ed (o)range (y)ellow ...
            pal1 "wKZ"  // palette 1: (w)hite blac(K) fractali(Z)e
            xfade (0..1 = 0.5)  // cross fade between pal0 and pal1
        }
        input {  // phone and tablet pencil input

            azimuth   // pen tilt

            accel  {  // accelerometer

                // use accel
                on (0..1) } radius (1..92 = 9)  // finger silhouette
            tilt (0..1)  // use tilt
            force (0..0.5)  // pen pressure
            >> sky.draw.brush.size }
        draw {  // draw on metal layer
            screen {  // fill 32 bit universe
                fillZero (0)  // all zeros 0x00000000
                fillOne (-1)  // all ones 0xFFFFFFFF
            }
            brush {  // type of brush and range
                type "dot"  // draw a circle
                size (1..64 = 10)  // range of radius
                press (0..1 = 1)  // pressure changes size
                index (1..255 = 127)  // index in 256 color palette
                                      // <<(osc.tuio.z osc.manos˚z) // redirect from OSC
            }
            line {  // place holder for line drawing
                prev   // staring point of segment
                next   // endint point of segment
            }
            scroll { offset  shift  } }
        shader {
            _compute { type "compute" file "*.metal" on (0..1) buffer { version (0..1) } }
            melt { type "compute" file "cell.melt.metal" on (0..1) buffer { version (0..1) } }
            fred { type "compute" file "cell.fred.metal" on (0..1) buffer { version (0..1) } }
            gas { type "compute" file "cell.gas.metal" on (0..1) buffer { version (0..1) } }
            ave { type "compute" file "cell.ave.metal" on (0..1) buffer { version (0..1) } }
            mod { type "compute" file "cell.mod.metal" on (0..1) buffer { version (0..1) } }
            fade { type "compute" file "cell.fade.metal" on (0..1) buffer { version (0..1) } }
            slide { type "compute" file "cell.slide.metal" on (0..1) buffer { version (0..1) } }
            drift { type "compute" file "cell.drift.metal" on (0..1) buffer { version (0..1) } }
            tunl { type "compute" file "cell.tunl.metal" on (0..1) buffer { version (0..1) } }
            zha { type "compute" file "cell.zha.metal" on (0..1)
                buffer { version (0..1) bits (2..4 = 3) } repeat (11) }
            record { type "record" file "record.metal" on (0..1) buffer { version (0..1) } flip (0..1) }
            camera { type "camera" file "cell.camera.metal" on (0..1) buffer { version (0..1) } flip (0..1) }
            camix { type "camix" file "cell.camix.metal" on (0..1) buffer { version (0..1) } flip (0..1) }
            draw { type "draw" file "pipe.draw.metal" on (0..1) buffer { scroll  } }
            color { type "color" file "pipe.color.metal" buffer { bitplane (0..1) } }
            render { type "render" file "pipe.render.metal"
                buffer { clip  repeat  mirror  } } } } midi
    panel {
        _cell {
            base { type "cell" title "_cell" frame  icon "icon.ring.white.png" }
            controls {
                hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                ruleOn { type "panelon" title "Active" frame  icon "icon.ring.white.png" value (0..1)  >> panel.cell˚ruleOn.value(0) lag (0) }
                version { type "segment" title "Version" frame  value (0..1 = 1) user  >> ruleOn.value(1) }
                lock { type "switch" title "Lock" frame
                    icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                fillZero {  // 00ffffde
                    type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                fillOne {  // ffffffde
                    type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
        _camera {
            base { type "cell" title "_cell"  // name
                frame  icon "icon.ring.white.png" }
            controls {
                hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                cameraOne { type "panelon" title "Camera Cell" frame  icon "icon.camera.png" value (0..1) lag (0) }
                version { type "segment" title "Version" frame  value (0..1 = 0.5) user  >> ruleOn.value(1) }
                cameraTwo { type "panelon" title "Camera Mix" frame  icon "icon.camera.flip.png" value (0..1) lag (0) }
                bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1) }
                facing { type "switch" title "Lock" frame  icon "icon.camera.flip.png" value (0..1)  >> sky.shader.camera.flip lag (0) } } }
        cell {
            fade {
                base { type "cell" title "Fade" frame  icon "icon.cell.fade.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.cell.fade.png" value (0..1)  >> panel.cell˚ruleOn.value(0) >> sky.shader.fade.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 0.5)  >> sky.shader.fade.buffer.version user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1 = 0.2)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            ave {
                base { type "cell" title "_cell" frame  icon "icon.ring.white.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.ring.white.png" value (0..1)  >> panel.cell˚ruleOn.value(0) lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 1) user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            melt {
                base { type "cell" title "Melt" frame  icon "icon.cell.melt.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.cell.melt.png" value (0..1)  >> panel.cell˚ruleOn.value(0) >> sky.shader.melt.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 1)  >> sky.shader.melt.buffer.version user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (1.67772e+07)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (1.67772e+07)  >> sky.draw.screen.fillOne } } }
            tunl {
                base { type "cell" title "Time Tunnel" frame  icon "icon.cell.tunl.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.cell.tunl.png" value (0..1)  >> panel.cell˚ruleOn.value(0) >> sky.shader.tunl.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 1)  >> sky.shader.tunl.buffer.version user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            zha {
                base { type "cell" title "_cell" frame  icon "icon.ring.white.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.ring.white.png" value (0..1)  >> panel.cell˚ruleOn.value(0) lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 1) user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            slide {
                base { type "cell" title "Slide Bit Planes" frame  icon "icon.cell.slide.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.cell.slide.png" value (0..1)  >> panel.cell˚ruleOn.value(0) >> sky.shader.slide.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 1)  >> sky.shader.slide.buffer.version user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            fred {
                base { type "cell" title "Fredkin" frame  icon "icon.cell.fred.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    ruleOn { type "panelon" title "Active" frame  icon "icon.cell.fred.png" value (0..1)  >> panel.cell˚ruleOn.value(0) >> sky.shader.fred.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 0.5)  >> sky.shader.fred.buffer.version user  >> ruleOn.value(1) }
                    lock { type "switch" title "Lock" frame
                        icon { off "icon.lock.closed.png" on "icon.lock.open.png" } value (0..1) lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillZero {  // 00ffffde
                        type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                    fillOne {  // ffffffde
                        type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            brush {
                base { type "brush" title "Brush" frame  icon "icon.cell.brush.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    brushSize { type "slider" title "Size" frame  value (0..1)  <> sky.draw.brush.size user  >> brushPress.value(0) }
                    brushPress { type "switch" title "Pressure" frame  icon "icon.pen.press.png" value (0..1)  <> sky.draw.brush.press }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillOne { type "trigger" title "clear 0xFFFF" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            scroll {
                base { type "cell" title "Scroll" frame  icon "icon.scroll.png" }
                controls {
                    scrollOn { type "panelon" title "Active" frame  icon "icon.scroll.png" value (0..1 = 0) lag (0) user  >> (scrollBox.value brushTilt.value(0)) }
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    scrollBox { type "box" title "Screen Scroll" frame  radius (10) tap2  lag (0) value   <> sky.input.azimuth >> sky.shader.draws.buffer.scroll user  >> (brushTilt.value(0) accelTilt.value(0) scrollOn.value(1)) }
                    brushTilt { type "switch" title "Brush Tilt" frame  icon "icon.pen.tilt.png" value (0..1)  <> sky.input.tilt >> accelTilt.value(0) }
                    fillZero { type "trigger" title "Fill Zero" frame  icon "icon.drop.clear.png" value (0..1)  >> sky.draw.screen.fillZero } } }
            camera {
                base { type "camera" title "Camera"  // name
                    frame  icon "icon.camera.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    cameraOne { type "panelon" title "Camera Cell" frame  icon "icon.camera.png" value (0..1)  >> sky.shader.camera.on lag (0) }
                    version { type "segment" title "Version" frame  value (0..1 = 0.5)  >> sky.shader.camix.buffer.version user  >> ruleOn.value(1) }
                    cameraTwo { type "panelon" title "Camera Mix" frame  icon "icon.camera.flip.png" value (0..1)  >> sky.shader.camix.on lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    facing { type "switch" title "Lock" frame  icon "icon.camera.flip.png" value (0..1)  >> sky.shader.camera.flip lag (0) } } }
            speed { restart  >> (speedOn(1) controls.speed.value(60))
                base { type "cell" title "Speed"  // name
                    frame  icon "icon.speed.png" }
                controls {
                    speedOn { type "panelon" title "Active" frame  icon "icon.speed.png" value (0..1)  >> sky.main.run user  >> scrollBox.value lag (0) }
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    speed { type "slider" title "Frames per second" frame  icon "icon.pearl.white.png" value (1..60 = 60)  <> sky.main.fps user  >> speedOn.value(1) } } } }
        shader {
            color {
                base { type "color" title "Color" frame  icon "icon.pal.main.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    palFade { type "slider" title "Palette Cross Fade" frame  icon "icon.pearl.white.png" value (0..1)  <> sky.color.xfade lag (0) }
                    bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1)  >> sky.shader.color.buffer.bitplane }
                    fillOne { type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } }
            tile {
                base { type "shader" title "Tile" frame  icon "icon.shader.tile.png" }
                controls {
                    hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                    tileOn { type "panelon" title "Active" frame  icon "icon.shader.tile.png" value (0..1) user  >> repeatBox.value lag (0) }
                    repeatBox { type "box" title "Repeat" frame  radius (10) tap2  lag (0) user (0..1 = 1)  >> tileOn.value(1) value   >> sky.shader.render.buffer.repeat }
                    mirrorBox { type "box" title "Mirror" frame  radius (10) tap2  lag (0) user (0..1 = 1) value   >> sky.shader.render.buffer.mirror } } } }
        record {
            base { type "record" title "Record" frame  icon "icon.record.png" }
            controls {
                hide { type "panelx" title "hide" frame  icon "icon.thumb.X.png" value (0..1) }
                ruleOn { type "panelon" title "Active" frame  icon "icon.record.png" value (0..1)  >> sky.shader.record.on lag (0) }
                version { type "segment" title "Version" frame  value (0..1 = 0.5)  >> sky.shader.record.buffer.version user  >> ruleOn.value(1) }
                lock { type "switch" title "Lock" frame  icon "icon.camera.flip.png" value  >> sky.shader.record.flip lag (0) }
                bitplane { type "slider" title "Bit Plane" frame  icon "icon.pearl.white.png" value (0..1 = 0.2) }
                fillZero { type "trigger" title "Fill Zeros" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillZero }
                fillOne { type "trigger" title "Fill Ones" frame  icon "icon.drop.gray.png" value (0..1)  >> sky.draw.screen.fillOne } } } } }
