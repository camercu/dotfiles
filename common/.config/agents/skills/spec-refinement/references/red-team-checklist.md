# Red-Team Checklist

Systematic stress-testing categories for Step 3. Attack each area relevant to the spec.

## Functional

- Missing edge cases (empty input, max values, concurrent access)
- Implicit assumptions not stated in requirements
- Requirements that contradict each other
- Undefined behavior gaps ("what happens when...?")

## Technical

- Performance under load — what's the expected scale?
- Data migration — does existing data need transformation?
- Backwards compatibility — do existing clients break?
- Failure modes — what happens when dependencies are down?
- State management — race conditions, partial failures, rollback

## Security

- Authentication / authorization gaps
- Input validation boundaries
- Data exposure in logs, errors, APIs
- Injection surfaces (SQL, command, XSS)

## Operational

- Monitoring — how do we know it's working?
- Rollback — how do we undo this safely?
- Feature flagging — can we ship dark and enable gradually?
- On-call impact — new failure modes to page on?

## UX / Integration

- User confusion points — is the mental model clear?
- API ergonomics — is the interface obvious to consumers?
- Error messages — actionable or cryptic?
- Documentation gaps — what needs updating?
