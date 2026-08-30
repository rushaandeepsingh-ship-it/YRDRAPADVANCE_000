CLASS yrdbp_r_ordertp_000 DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF yrdr_ordertp_000.

  PUBLIC SECTION.

    TYPES : tyt_orderstatusupdated TYPE TABLE FOR EVENT yrdr_ordertp_000~orderStatusUpdated.

    CLASS-METHODS :
      raise_orderstatusupdated IMPORTING it_events TYPE tyt_orderstatusupdated.

ENDCLASS.

CLASS yrdbp_r_ordertp_000 IMPLEMENTATION.

  METHOD raise_orderstatusupdated.

    RAISE ENTITY EVENT yrdr_ordertp_000~orderStatusUpdated
      FROM it_events.

  ENDMETHOD.

ENDCLASS.
