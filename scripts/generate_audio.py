import math
import struct
import wave
import random
import os

SAMPLE_RATE = 22050  # Compact and good quality

def save_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        # Normalize and convert to 16-bit PCM
        max_val = max(max(abs(s) for s in samples), 0.001)
        scaling = 30000.0 / max_val
        
        packed_data = bytearray()
        for s in samples:
            clamped = max(-32767, min(32767, int(s * scaling)))
            packed_data.extend(struct.pack('<h', clamped))
            
        wav_file.writeframes(packed_data)
    print(f"Generated {filename} ({len(samples)/SAMPLE_RATE:.1f}s)")

def note_freq(midi_note):
    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))

# 1. Piano Peaceful: Cmaj - Gmaj - Amin - Fmaj chord arpeggios with piano envelope
def generate_piano():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples
    
    # Chords (MIDI notes)
    # C major: C3, G3, C4, E4, G4 (48, 55, 60, 64, 67)
    # G major: G2, D3, G3, B3, D4 (43, 50, 55, 59, 62)
    # A minor: A2, E3, A3, C4, E4 (45, 52, 57, 60, 64)
    # F major: F2, C3, F3, A3, C4 (41, 48, 53, 57, 60)
    chord_progression = [
        [48, 55, 60, 64, 67, 72],
        [43, 50, 55, 59, 62, 67],
        [45, 52, 57, 60, 64, 69],
        [41, 48, 53, 57, 60, 65]
    ]
    
    chord_dur = 4.0
    for c_idx, chord in enumerate(chord_progression):
        start_time = c_idx * chord_dur
        # Arpeggiate notes in the chord
        for n_idx, note in enumerate(chord):
            n_start = start_time + (n_idx * 0.45)
            freq = note_freq(note)
            n_samples = int(SAMPLE_RATE * (duration - n_start))
            
            for i in range(min(n_samples, int(SAMPLE_RATE * 5.0))):
                t = i / SAMPLE_RATE
                target_idx = int(n_start * SAMPLE_RATE) + i
                if target_idx >= total_samples:
                    break
                # Piano timbre: fundamental + 2nd + 3rd harmonic with decay
                env = math.exp(-t * 2.2) * (1.0 - math.exp(-t * 80.0))
                val = (math.sin(2 * math.pi * freq * t) +
                       0.5 * math.sin(2 * math.pi * freq * 2 * t) * math.exp(-t * 1.5) +
                       0.25 * math.sin(2 * math.pi * freq * 3 * t) * math.exp(-t * 2.5) +
                       0.1 * math.sin(2 * math.pi * freq * 4 * t) * math.exp(-t * 4.0)) * env
                output[target_idx] += val
                
    # Smooth loop edges
    fade_len = int(SAMPLE_RATE * 0.2)
    for i in range(fade_len):
        fade = i / fade_len
        output[i] *= fade
        output[total_samples - 1 - i] *= fade
    return output

# 2. Acoustic Meditation: Fingerpicking acoustic resonance
def generate_acoustic():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples
    
    # D - A - Bm - G progression (warm acoustic feeling)
    patterns = [
        [50, 57, 62, 66, 69], # D
        [45, 52, 57, 61, 64], # A
        [47, 54, 59, 62, 66], # Bm
        [43, 50, 55, 59, 62]  # G
    ]
    
    for p_idx, chord in enumerate(patterns):
        base_t = p_idx * 4.0
        # Gentle fingerpicking rhythm
        pick_times = [0.0, 0.4, 0.8, 1.3, 1.8, 2.2, 2.7, 3.2]
        for step, pt in enumerate(pick_times):
            note = chord[step % len(chord)]
            t_note = base_t + pt
            freq = note_freq(note)
            
            for i in range(int(SAMPLE_RATE * 3.5)):
                idx = int(t_note * SAMPLE_RATE) + i
                if idx >= total_samples:
                    break
                t = i / SAMPLE_RATE
                env = math.exp(-t * 3.0) * (1.0 - math.exp(-t * 150.0))
                # Acoustic string tone (rich even & odd harmonics)
                val = (math.sin(2 * math.pi * freq * t) +
                       0.6 * math.sin(2 * math.pi * freq * 2 * t) +
                       0.3 * math.sin(2 * math.pi * freq * 3 * t) +
                       0.15 * math.sin(2 * math.pi * freq * 4 * t)) * env
                output[idx] += val
                
    fade_len = int(SAMPLE_RATE * 0.2)
    for i in range(fade_len):
        fade = i / fade_len
        output[i] *= fade
        output[total_samples - 1 - i] *= fade
    return output

# 3. Ambient Worship: Celestial pads with slow swells and ethereal harmonics
def generate_ambient():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples
    
    # Continuous lush pad chords: C major 9 (48, 55, 60, 62, 64, 71) -> F major 7 (41, 48, 53, 57, 64, 69)
    chords = [
        ([48, 55, 60, 62, 64, 71], 0.0, 8.0),
        ([41, 48, 53, 57, 64, 69], 8.0, 16.0)
    ]
    
    for notes, start_t, end_t in chords:
        dur = end_t - start_t
        for note in notes:
            freq = note_freq(note)
            for i in range(int(dur * SAMPLE_RATE)):
                idx = int(start_t * SAMPLE_RATE) + i
                if idx >= total_samples:
                    break
                t = i / SAMPLE_RATE
                # Smooth sinusoidal swell and release
                swell = math.sin(math.pi * (t / dur))
                # Gentle shimmer LFO
                lfo = 1.0 + 0.08 * math.sin(2 * math.pi * 0.4 * t)
                # Subtle detune for wide celestial feel
                detune1 = freq * 0.998
                detune2 = freq * 1.002
                tone = (math.sin(2 * math.pi * freq * t) +
                        0.5 * math.sin(2 * math.pi * detune1 * t) +
                        0.5 * math.sin(2 * math.pi * detune2 * t) +
                        0.25 * math.sin(2 * math.pi * freq * 2 * t))
                output[idx] += tone * swell * lfo * 0.2
                
    return output

# 4. Lofi Chill: Mellow vintage Rhodes chords with gentle tape warmth
def generate_lofi():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples
    
    # Jazz/chill chords: Dm9 -> G13 -> Cmaj9 -> Am7
    chords = [
        [50, 57, 60, 64, 69], # Dm9
        [43, 53, 57, 62, 67], # G13
        [48, 55, 59, 64, 71], # Cmaj9
        [45, 52, 55, 60, 67]  # Am7
    ]
    
    for c_idx, chord in enumerate(chords):
        start_t = c_idx * 4.0
        for note in chord:
            freq = note_freq(note)
            for i in range(int(SAMPLE_RATE * 3.8)):
                idx = int(start_t * SAMPLE_RATE) + i
                if idx >= total_samples:
                    break
                t = i / SAMPLE_RATE
                env = math.exp(-t * 0.9) * (1.0 - math.exp(-t * 40.0))
                # Warm bell-like Rhodes sound
                tone = (math.sin(2 * math.pi * freq * t) +
                        0.4 * math.sin(2 * math.pi * freq * 2 * t) * math.exp(-t * 2.0) +
                        0.2 * math.sin(2 * math.pi * freq * 3 * t) * math.exp(-t * 3.0))
                # Subtle tape flutter
                flutter = 1.0 + 0.02 * math.sin(2 * math.pi * 3.5 * t)
                output[idx] += tone * env * flutter * 0.25
                
    return output

# 5. Nature Rain: Peaceful gentle rain ambiance with soft water droplets
def generate_nature_rain():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples
    
    random.seed(42)
    # Cascaded 3-pole IIR lowpass filter to produce warm, soft continuous rainfall
    lp1 = 0.0
    lp2 = 0.0
    lp3 = 0.0
    
    rain_stream = [0.0] * total_samples
    for i in range(total_samples):
        white = (random.random() * 2.0) - 1.0
        # Multi-stage smoothing: cuts out harsh TV-static hiss and leaves gentle rainfall patter
        lp1 = lp1 * 0.85 + white * 0.15
        lp2 = lp2 * 0.82 + lp1 * 0.18
        lp3 = lp3 * 0.78 + lp2 * 0.22
        
        # Very gentle natural breathing rhythm of rainfall intensity
        t = i / SAMPLE_RATE
        breeze = 0.75 + 0.20 * math.sin(2 * math.pi * 0.06 * t) + 0.05 * math.sin(2 * math.pi * 0.15 * t)
        rain_stream[i] = lp3 * breeze

    # Gentle, soft water droplet resonances (smooth sine pulses with exponential decay, NOT static clicks)
    droplets = [0.0] * total_samples
    drop_times = [
        0.35, 0.82, 1.45, 2.10, 2.75, 3.40, 4.15, 4.90, 5.60, 6.25, 7.05, 7.80,
        8.45, 9.15, 9.85, 10.55, 11.30, 12.05, 12.75, 13.40, 14.10, 14.85, 15.45
    ]
    for dt in drop_times:
        freq = random.uniform(900, 1700)
        drop_dur = 0.05  # 50 ms soft droplet
        drop_samples = int(drop_dur * SAMPLE_RATE)
        start_idx = int(dt * SAMPLE_RATE)
        for j in range(drop_samples):
            idx = start_idx + j
            if idx >= total_samples:
                break
            tj = j / SAMPLE_RATE
            # Hann window * exponential decay = smooth, click-free water droplet
            env = math.sin(math.pi * (tj / drop_dur)) * math.exp(-tj * 50.0)
            droplets[idx] += math.sin(2 * math.pi * freq * tj) * env * 0.06

    for i in range(total_samples):
        output[i] = rain_stream[i] * 0.75 + droplets[i] * 0.25

    # Equal-power seamless loop crossfade (1.2 seconds)
    fade_len = int(SAMPLE_RATE * 1.2)
    for i in range(fade_len):
        fade = i / fade_len
        # Crossfade start and end
        start_val = output[i]
        end_val = output[total_samples - fade_len + i]
        blended = start_val * fade + end_val * (1.0 - fade)
        output[i] = blended
        output[total_samples - fade_len + i] = blended

    return output

# 6. Orchestral Strings: Reverent cathedral string ensemble with rich warm chords
def generate_orchestral():
    duration = 16.0
    total_samples = int(SAMPLE_RATE * duration)
    output = [0.0] * total_samples

    # Sacred worship progression: Cmaj -> Fmaj -> Am7 -> Gmaj
    # Voiced warmly in cello/viola/violin registers without muddy sub-bass rumble
    chords = [
        [48, 55, 60, 64, 67],  # C major (C3, G3, C4, E4, G4)
        [41, 48, 53, 57, 60],  # F major (F2, C3, F3, A3, C4)
        [45, 52, 57, 60, 64],  # A minor (A2, E3, A3, C4, E4)
        [43, 50, 55, 59, 62],  # G major (G2, D3, G3, B3, D4)
    ]

    chord_interval = 4.0   # Each chord holds for 4.0s
    chord_sound_dur = 5.2  # 5.2s duration allows 1.2s smooth overlap / crossfade between chords!

    for c_idx, chord in enumerate(chords):
        chord_start = c_idx * chord_interval
        for note in chord:
            freq = note_freq(note)
            # Ensemble chorus voices: fundamental, +0.2% detuned, -0.2% detuned
            voices = [
                (freq, 1.0),
                (freq * 1.002, 0.55),
                (freq * 0.998, 0.55),
                (freq * 2.0, 0.35),       # Octave overtone
                (freq * 3.0, 0.15),       # Fifth harmonic
            ]

            note_samples = int(chord_sound_dur * SAMPLE_RATE)
            for i in range(note_samples):
                t = i / SAMPLE_RATE
                target_idx = int(chord_start * SAMPLE_RATE) + i

                # Smooth bow envelope: gentle attack (0.9s), sustain, gentle release (1.2s)
                if t < 0.9:
                    env = 0.5 * (1.0 - math.cos(math.pi * (t / 0.9)))
                elif t > chord_sound_dur - 1.2:
                    rel_t = (chord_sound_dur - t) / 1.2
                    env = 0.5 * (1.0 - math.cos(math.pi * rel_t))
                else:
                    env = 1.0

                # Natural string ensemble tremolo/shimmer (slow and sacred)
                tremolo = 1.0 + 0.04 * math.sin(2 * math.pi * 4.8 * t)

                # Sum all chorus voices
                tone = 0.0
                for v_freq, v_gain in voices:
                    tone += math.sin(2 * math.pi * v_freq * t) * v_gain

                val = tone * env * tremolo * 0.04

                # Wrap around seamlessly into start of next loop cycle if target_idx >= total_samples
                if target_idx < total_samples:
                    output[target_idx] += val
                else:
                    output[target_idx - total_samples] += val

    # Seamless boundary crossfade for continuous click-free looping
    fade_len = int(SAMPLE_RATE * 1.0)
    for i in range(fade_len):
        fade = i / fade_len
        output[i] = output[i] * fade + output[total_samples - fade_len + i] * (1.0 - fade)
        output[total_samples - fade_len + i] = output[i]

    return output

if __name__ == '__main__':
    out_dir = "assets/audio"
    save_wav(os.path.join(out_dir, "piano_peaceful.wav"), generate_piano())
    save_wav(os.path.join(out_dir, "acoustic_meditation.wav"), generate_acoustic())
    save_wav(os.path.join(out_dir, "ambient_worship.wav"), generate_ambient())
    save_wav(os.path.join(out_dir, "lofi_chill.wav"), generate_lofi())
    save_wav(os.path.join(out_dir, "nature_rain.wav"), generate_nature_rain())
    save_wav(os.path.join(out_dir, "orchestral_strings.wav"), generate_orchestral())
    print("All audio files generated successfully!")
