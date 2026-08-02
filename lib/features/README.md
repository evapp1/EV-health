# Feature presentation boundary

Feature folders own screens, widgets, controllers, and screen-specific view
data. Presentation may call application use cases and consume domain view data;
it must never import infrastructure implementations or contain business logic.
