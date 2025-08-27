#import "lib.typ": *
#import "indorsement.typ": Indorsement

#OfficialMemorandum(
  indorsements: (
    Indorsement(
      office_symbol: "31 MXG/CC",
      memo_for: "31 FW/CC",
      signature_block: (
        "JANE B. DOE, Lt Col, USAF",
        "Commander"
      ),
      body: [This request has been reviewed and is approved for forwarding to wing level for final approval.],
      pagebreak: true  // This indorsement will start on a new page
    ),
    Indorsement(
      office_symbol: "31 FW/CC", 
      memo_for: "31 MXG/MXQ",
      signature_block: (
        "ROBERT C. JOHNSON, Col, USAF",
        "Commander"
      ),
      body: [Request approved. Please coordinate implementation with all affected units.],
    )
  )
)[

This memorandum demonstrates the official format for Air Force correspondence with multiple indorsements. The original request is being forwarded through the chain of command for approval and action.

The memorandum follows AFH 33-337 standards for formatting, spacing, and content organization. All elements are positioned according to regulation specifications.

This example shows how indorsements are used to document the flow of correspondence through multiple organizational levels, with each indorsing official adding their comments and signature.

Please review and provide guidance on the proposed action. If you have any questions, please contact MSgt Smith at 632-8620.
]
