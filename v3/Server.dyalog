﻿    :Class Server 
        :Field Public LIB
        :Field Public address
        :Field Public service 
        :Field Public timeout
        :Field Public extra
        :Field Private name

        :Field Private htid
        :Field Private done
        :Field Private HError 
        :Field Private conclass 
        :Field Private events 
        :Field Private CaptureStats

          Assert←{
              ⍺=⊃⍵:⍵
              ('Server error: ',⍕⍵)⎕SIGNAL 999
          }
          obj2ref←{⍺← ⎕this
              spilt← '.'∘{ p←⍵⍳⍺⋄ ((p-1)↑⍵) (p↓⍵)   }
              9=⍺.⎕nc ⊃(h t)←split ⍵: (⍺⍎h) ∇ t
              ⍺ 
          }
          

        ∇ ref←Conga
          :Access Public Shared
          ref←## ⍝ Conga is the parent (as things stand)
        ∇

        ∇ makeN arg
          :Access Public
          :Implements Constructor
          enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
          defaults←{⍺,(⍴,⍺)↓⍵}
          done←¯1
          timeout←5000
          HError←0
          events←⍬     
          CaptureStats←0
          'Please use Conga.Srv to instantiate Servers' ⎕SIGNAL (Conga≡#)/11
          (LIB service conclass address extra)←(enc arg)defaults ⍬ 5000 Conga.Connection''(⎕NS'')
          :If LIB≡⍬
              LIB←Conga.Init''
          :EndIf
        ∇
    
        ∇ unmake;cons
          :Implements Destructor
          Stop
        ∇

   
        ∇ Start;err;sp;p
          :Access Public
          (err name)←0 Assert LIB.Srv''address service,conclass.ServerArgs
          done←0
          sp←⎕THIS conclass.ServerProperties name
          :If 0<⍴sp
              :For p :In sp
                  _←LIB.SetProp(⊂name),p
              :EndFor
          :EndIf
         
          htid←Handler&name
        ∇
    
        ∇ Stop
          :Access Public
          :If done=¯1 ⋄ :Return ⋄:EndIf

          done←1
          cons←LIB.Names name
          :If 0≠⎕NC name         
              (⍎name).(⎕EX¨⎕NL 9)  ⍝ Clear all the Connection instances
              ⎕EX name             ⍝ Clear the namespace for all the instances
              _←LIB.Close name     ⍝ Close the server
              ⎕DL timeout÷1000     ⍝ wait for Wait to return
          :EndIf
          
          :If 0≠⎕nc'htid'
          :AndIf htid≠0           ⍝ if thread have not ended by it self kill it
              ⎕TKILL htid
          :EndIf
        ∇

        ∇ onTimeout
          :Access Public Overridable
        ∇      

        ∇ Handler name;r;newcon;err;obj;evt;data;tss
          ⍎name,'←⎕ns '''' '
          :While ~done
              :if CaptureStats
              (err obj evt data tss)←5↑r←LIB.Waitt name timeout  
               Timings⍪←6↑tss
              :else
              (err obj evt data)←4↑r←LIB.Wait name timeout  
              :endif
              :Select err              
              :Case 0
                  :Select evt
                  :Case 'Connect'
                      newcon←⎕NEW conclass(obj ⎕THIS extra)
                      :If events≡⍬
                          events←2↓¨'on'{((⊂⍺)≡¨(⍴,⍺)↑¨⍵)/⍵}newcon.⎕NL ¯3
                      :EndIf
                      ⍎obj,'← newcon'
                      ⎕EX'newcon'
                  :Case 'Error'
                      (⍎obj).onError obj data
                      Remove obj  
                  :Case 'Closed'
                      (⍎obj).onClose obj data
                      Remove obj  
                  :Case 'Receive'
                      ⍎('.'{(-(⌽⍵)⍳⍺)↓⍵}obj),'.on',evt,'& obj data'
                  :Case 'Timeout'
                      onTimeout
                  :Else
                      :If ∨/events∊⊂evt
                          ⍎('.'{1<≢ix← {⍵/⍳⍴⍵}⍺=⍵:(¯1+2⊃ix)↑⍵⋄⍵}obj),'.on',evt,'& obj data'
                      :Else
                          _←LIB.Close name
                          'unexpected event'⎕SIGNAL 999
                      :EndIf
                  :EndSelect    
              :Case 100 ⍝ Timeout with EventMode=0
                  onTimeout          
              :Case 1119 ⍝ Close with EventMode=0    
                  (⍎obj).onClose obj data
                  Remove obj
              :Else
                  HError←⊃r
                  done←1
              :EndSelect
          :EndWhile
          htid←0
        ∇
        
        ∇ Remove obj
          :Access Public
          _←⎕EX obj
          _←LIB.Close obj
        ∇
        
        ∇EnableStats arg
        :access public  
        :if arg>0
        Timings←1 6⍴0
        CaptureStats←1
        :else
         CaptureStats←0
        :endif
        ∇  
        
        ∇r←GetStats 
        :access public 
         r←Timings
        ∇
    :EndClass
