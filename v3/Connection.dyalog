﻿:Class Connection
    :Field Public srv   ⍝ reference to Server started the Connection
    :Field Public Name
    :Field Public extra

    ∇ ct←ServerArgs
      :Access Public Shared
        ⍝ return the type of connection you want
      ct←,⊂'Command'
    ∇

    ∇ sp←srv ServerProperties name
      :Access Public Shared
         ⍝ Return the Properties to set for the server or
         ⍝ use the srv ref to access srv and srv.LIB and do it yourself
      sp←⍬
    ∇

    ∇ e←Progress(obj data)
      :Access Public
      e←srv.LIB.Progress obj data
    ∇

    ∇ e←Respond(obj data)
      :Access Public
      e←srv.LIB.Respond obj data
    ∇

    ∇ e←Send(data close)
      :Access Public
      e←srv.LIB.Send Name data close
    ∇

    ∇ Close obj
      :Access Public
      srv.Remove Name
      _←srv.LIB.Close Name
    ∇


    ∇ makeN arg
      :Access Public
      :Implements Constructor
      enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
      defaults←{⍺,(⍴,⍺)↓⍵}
     
      (Name srv extra)←(enc arg)defaults''⍬(⎕NS'')
    ∇

    ∇ r←Test
      :Access Public
      r←42
    ∇

    ∇ onReceive(obj data)
      :Access Public Overridable
      Respond obj(⌽data)
    ∇

    ∇ onError(obj data)
      :Access Public Overridable
      ⍝ ⎕←'Oh no ',obj,' has failed with error ',⍕data
    ∇
    
    ∇ onClose(obj data)
      :Access Public Overridable
      ⍝ ⎕←'Closed: ',⍕obj
    ∇
    
:EndClass
