# Panel: Threat Modeling

## Purpose
Systematic threat analysis mapping attack surfaces to MITRE ATT&CK, identifying kill chains, and producing actionable detection and mitigation strategies.

## Participants
- **MITRE Specialist** - ATT&CK technique mapping, kill chain analysis, detection gaps
- **Security Auditor** - Vulnerability identification, exploit feasibility
- **Infrastructure Engineer** - Network boundaries, IAM policies, encryption posture
- **Adversarial Reviewer** - Attack vector creativity, hidden assumptions, invariant violations
- **Architect** - System boundaries, trust zones, data flow exposure

## Process
1. Define system scope, trust boundaries, and data flows
2. MITRE Specialist maps attack surface to ATT&CK tactics
3. Each participant identifies threats from their perspective
4. Build attack trees for high-value targets
5. Assess detection coverage per ATT&CK technique
6. Prioritize by likelihood and impact
7. Produce mitigation and detection recommendations

## Output Format
### Per Participant
- Perspective name
- Threats identified with ATT&CK technique IDs (where applicable)
- Severity and likelihood rating
- Recommended mitigations or detections

### Consolidated
- Threat model summary with ATT&CK mapping
- Kill chain analysis for top threat scenarios
- Detection gap matrix
- Prioritized mitigation roadmap
- Residual risk assessment

## Constraints
- Every threat must reference a specific ATT&CK technique where one exists
- Distinguish between prevention controls and detection controls
- Prioritize by adversary capability and asset value
- Provide actionable detection rules, not just risk descriptions
