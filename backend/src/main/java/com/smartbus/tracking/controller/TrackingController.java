package com.smartbus.tracking.controller;

import com.smartbus.tracking.dto.LocationUpdate;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.messaging.simp.SimpMessagingTemplate;

@Controller
public class TrackingController {
    private final SimpMessagingTemplate messaging;
    public TrackingController(SimpMessagingTemplate messaging) { this.messaging = messaging; }

    @MessageMapping("/updateLocation")
    public LocationUpdate processLocationUpdate(LocationUpdate update) {
        messaging.convertAndSend("/topic/busLocations", update);
        return update;
    }
}
