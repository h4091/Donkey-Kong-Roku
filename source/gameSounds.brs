' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Donkey Kong Channel - http://github.com/lvcabral/Donkey-Kong-Roku
' **
' **  Created: November 2016
' **  Updated: February 2017
' **
' **  Remake in BrigthScript developed by Marcelo Lv Cabral - http://lvcabral.com
' ********************************************************************************************************
' ********************************************************************************************************

Function LoadSounds(enable as boolean) as object
    sounds = {  enabled:enable,
                folder: "pkg:/assets/audio/",
                mp3: {clip:"", priority:0, cycles:0},
                wav: [{clip:"", priority:0, cycles:0}, {clip:"", priority:0, cycles:0}],
                navSingle : CreateObject("roAudioResource", "navsingle"),
                select : CreateObject("roAudioResource", "select")
             }
    sounds.metadata = ParseJson(ReadAsciiFile(sounds.folder + "sounds.json"))
    for each name in sounds.metadata.clips
        clip = sounds.metadata.clips.Lookup(name)
        if clip.type = "wav"
            sounds.AddReplace(name,CreateObject("roAudioResource", sounds.folder + name + ".wav"))
        end if
    next
    sounds.maxWav = sounds.select.maxSimulStreams()
    print "max wav streams:"; sounds.maxWav
    return sounds
End Function

Function IsSilent() as boolean
    return (m.sounds.mp3.cycles = 0 and m.sounds.wav[0].cycles = 0 and m.sounds.wav[1].cycles = 0)
End Function

Sub SoundUpdate()
    if not m.sounds.enabled then return
    m.audioPort.GetMessage()
    if m.sounds.mp3.cycles > 0
        m.sounds.mp3.cycles -= 1
    end if
    if m.sounds.wav[0].cycles > 0
        m.sounds.wav[0].cycles -= 1
    end if
    if m.sounds.wav[1].cycles > 0
        m.sounds.wav[1].cycles -= 1
    end if
End Sub

Sub PlaySound(clip as string, overlap = false as boolean, volume = 75 as integer)
    g = GetGlobalAA()
    meta = g.sounds.metadata.clips.Lookup(clip)
    if meta = invalid then return
    if meta.type = "mp3"
        PlaySoundMp3(meta, clip, overlap)
    else
        PlaySoundWav(meta, clip, volume)
    end if
End Sub

Sub PlaySoundMp3(meta as object, clip as string, overlap as boolean)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    ctrl = g.sounds.mp3
    if ctrl.cycles = 0 or meta.priority > ctrl.priority or (ctrl.clip = clip and overlap)
        'print "play sound mp3: "; clip
        ctrl.clip = clip
        ctrl.priority = meta.priority
        ctrl.cycles = cint(meta.duration / g.speed)
        g.audioPlayer.SetContentList([{url: g.sounds.folder + clip + ".mp3"}])
        g.audioPlayer.setLoop(false)
        g.audioPlayer.play()
    end if
End Sub

Sub PlaySoundWav(meta as object, clip as string, volume = 75 as integer)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    channel = -1
    ctrl = g.sounds.wav
    for c = 0 to 1
        if ctrl[c].cycles = 0
            channel = c
        else if meta.priority > ctrl[c].priority
            channel = c
        else if ctrl[c].clip = clip
            return
        end if
    next
    if channel >= 0
        sound = g.sounds.Lookup(clip)
        print "play sound wav: "; clip
        sound.Trigger(volume, channel)
        ctrl[channel].clip = clip
        ctrl[channel].priority = meta.priority
        ctrl[channel].cycles = cint(meta.duration / g.speed)
    end if
End Sub

Sub PlaySong(clip as string, loop = false as boolean)
    g = GetGlobalAA()
    if g.sounds.enabled
        g.audioPlayer.SetContentList([{url:"pkg:/assets/audio/" + clip + ".mp3"}])
        g.audioPlayer.setLoop(loop)
        g.audioPlayer.play()
    end if
End Sub

Sub StopAudio()
    g = GetGlobalAA()
    if g.sounds.enabled
        g.audioPlayer.stop()
        g.sounds.mp3 = {clip:"", priority:0, cycles:0}
    end if
End Sub

Sub StopSound()
    g = GetGlobalAA()
    if g.sounds.enabled
        for s = 0 to 1
            wav = g.sounds.Lookup(g.sounds.wav[s].clip)
            if wav <> invalid and wav.IsPlaying()
                wav.Stop()
            end if
            g.sounds.wav[s] = {clip:"", priority:0, cycles:0}
        next
    end if
End Sub
