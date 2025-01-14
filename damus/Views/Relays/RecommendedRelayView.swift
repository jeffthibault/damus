//
//  RecommendedRelayView.swift
//  damus
//
//  Created by William Casarin on 2022-12-29.
//

import SwiftUI

struct RecommendedRelayView: View {
    let damus: DamusState
    let relay: String
    let add_button: Bool
    
    @Binding var showActionButtons: Bool
    
    init(damus: DamusState, relay: String, add_button: Bool = true, showActionButtons: Binding<Bool>) {
        self.damus = damus
        self.relay = relay
        self.add_button = add_button
        self._showActionButtons = showActionButtons
    }
    
    var body: some View {
        ZStack {
            HStack {
                if let keypair = damus.keypair.to_full() {
                    if showActionButtons && add_button {
                        AddButton(keypair: keypair, showText: false)
                    }
                }
                
                RelayType(is_paid: damus.relay_model_cache.model(with_relay_id: relay)?.metadata.is_paid ?? false)
                
                Text(relay).layoutPriority(1)

                if let meta = damus.relay_model_cache.model(with_relay_id: relay)?.metadata {
                    NavigationLink(value: Route.RelayDetail(relay: relay, metadata: meta)){
                        EmptyView()
                    }
                    .opacity(0.0)
                    .disabled(showActionButtons)
                    
                    Spacer()
                    
                    Image("info")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.accentColor)
                } else {
                    Spacer()

                    Image("question")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
            }
        }
        .swipeActions {
            if add_button {
                if let keypair = damus.keypair.to_full() {
                    AddButton(keypair: keypair, showText: false)
                        .tint(.accentColor)
                }
            }
        }
        .contextMenu {
            CopyAction(relay: relay)
            
            if let keypair = damus.keypair.to_full() {
                AddButton(keypair: keypair, showText: true)
            }
        }
    }
    
    func CopyAction(relay: String) -> some View {
        Button {
            UIPasteboard.general.setValue(relay, forPasteboardType: "public.plain-text")
        } label: {
            Label(NSLocalizedString("Copy", comment: "Button to copy a relay server address."), image: "copy")
        }
    }
    
    func AddButton(keypair: FullKeypair, showText: Bool) -> some View {
        Button(action: {
            add_action(keypair: keypair)
        }) {
            if showText {
                Text(NSLocalizedString("Connect", comment: "Button to connect to recommended relay server."))
            }
            Image("plus-circle")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.accentColor)
                .padding(.leading, 5)
        }
    }
    
    func add_action(keypair: FullKeypair) {
        guard let ev_before_add = damus.contacts.event else {
            return
        }
        guard let ev_after_add = add_relay(ev: ev_before_add, keypair: keypair, current_relays: damus.pool.our_descriptors, relay: relay, info: .rw) else {
            return
        }
        process_contact_event(state: damus, ev: ev_after_add)
        damus.postbox.send(ev_after_add)
    }
}

struct RecommendedRelayView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedRelayView(damus: test_damus_state(), relay: "wss://relay.damus.io", showActionButtons: .constant(false))
    }
}
