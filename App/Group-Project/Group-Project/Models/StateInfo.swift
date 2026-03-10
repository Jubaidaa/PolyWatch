import SwiftUI

struct StateInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let abbreviation: String
    let registrationURL: String
    
    static let allStates: [StateInfo] = [
        StateInfo(name: "Alabama", abbreviation: "AL", registrationURL: "https://www.alabamavotes.gov/olvr/default.aspx"),
        StateInfo(name: "Alaska", abbreviation: "AK", registrationURL: "https://voterregistration.alaska.gov/"),
        StateInfo(name: "Arizona", abbreviation: "AZ", registrationURL: "https://servicearizona.com/voterRegistration"),
        StateInfo(name: "Arkansas", abbreviation: "AR", registrationURL: "https://www.sos.arkansas.gov/elections/voter-information/register-to-vote"),
        StateInfo(name: "California", abbreviation: "CA", registrationURL: "https://registertovote.ca.gov/"),
        StateInfo(name: "Colorado", abbreviation: "CO", registrationURL: "https://www.sos.state.co.us/voter/pages/pub/olvr/verifyNewVoter.xhtml"),
        StateInfo(name: "Connecticut", abbreviation: "CT", registrationURL: "https://voterregistration.ct.gov/OLVR/welcome.do"),
        StateInfo(name: "Delaware", abbreviation: "DE", registrationURL: "https://ivote.de.gov/voterview"),
        StateInfo(name: "Florida", abbreviation: "FL", registrationURL: "https://registertovoteflorida.gov/"),
        StateInfo(name: "Georgia", abbreviation: "GA", registrationURL: "https://registertovote.sos.ga.gov/"),
        StateInfo(name: "Hawaii", abbreviation: "HI", registrationURL: "https://olvr.hawaii.gov/"),
        StateInfo(name: "Idaho", abbreviation: "ID", registrationURL: "https://elections.sos.idaho.gov/ElectionLink/ElectionLink/ApplicationInstructions.aspx"),
        StateInfo(name: "Illinois", abbreviation: "IL", registrationURL: "https://ova.elections.il.gov/"),
        StateInfo(name: "Indiana", abbreviation: "IN", registrationURL: "https://indianavoters.in.gov/"),
        StateInfo(name: "Iowa", abbreviation: "IA", registrationURL: "https://mymvd.iowadot.gov/Account/Login"),
        StateInfo(name: "Kansas", abbreviation: "KS", registrationURL: "https://www.kdor.ks.gov/apps/voterreg/default.aspx"),
        StateInfo(name: "Kentucky", abbreviation: "KY", registrationURL: "https://vrsws.sos.ky.gov/ovrweb/"),
        StateInfo(name: "Louisiana", abbreviation: "LA", registrationURL: "https://voterportal.sos.la.gov/"),
        StateInfo(name: "Maine", abbreviation: "ME", registrationURL: "https://www.maine.gov/portal/government/edemocracy/voter_lookup.php"),
        StateInfo(name: "Maryland", abbreviation: "MD", registrationURL: "https://voterservices.elections.maryland.gov/OnlineVoterRegistration/InstructionsStep1"),
        StateInfo(name: "Massachusetts", abbreviation: "MA", registrationURL: "https://www.sec.state.ma.us/ovr/"),
        StateInfo(name: "Michigan", abbreviation: "MI", registrationURL: "https://mvic.sos.state.mi.us/"),
        StateInfo(name: "Minnesota", abbreviation: "MN", registrationURL: "https://mnvotes.sos.state.mn.us/VoterRegistration/VoterRegistrationMain.aspx"),
        StateInfo(name: "Mississippi", abbreviation: "MS", registrationURL: "https://www.sos.ms.gov/elections-voting/voter-registration-information"),
        StateInfo(name: "Missouri", abbreviation: "MO", registrationURL: "https://s1.sos.mo.gov/elections/voterregistration/"),
        StateInfo(name: "Montana", abbreviation: "MT", registrationURL: "https://app.mt.gov/voterinfo/"),
        StateInfo(name: "Nebraska", abbreviation: "NE", registrationURL: "https://www.nebraska.gov/apps-sos-voter-registration/"),
        StateInfo(name: "Nevada", abbreviation: "NV", registrationURL: "https://www.nvsos.gov/sosvoterservices/Registration/step1.aspx"),
        StateInfo(name: "New Hampshire", abbreviation: "NH", registrationURL: "https://app.sos.nh.gov/Public/PartyInfo.aspx"),
        StateInfo(name: "New Jersey", abbreviation: "NJ", registrationURL: "https://voter.svrs.nj.gov/register"),
        StateInfo(name: "New Mexico", abbreviation: "NM", registrationURL: "https://portal.sos.state.nm.us/OVR/WebPages/InstructionsStep1.aspx"),
        StateInfo(name: "New York", abbreviation: "NY", registrationURL: "https://dmv.ny.gov/more-info/electronic-voter-registration-application"),
        StateInfo(name: "North Carolina", abbreviation: "NC", registrationURL: "https://www.ncdot.gov/dmv/offices-services/online/Pages/voter-registration.aspx"),
        StateInfo(name: "North Dakota", abbreviation: "ND", registrationURL: "https://vip.sos.nd.gov/PortalListDetails.aspx?ptlhPKID=65&ptlPKID=7"),
        StateInfo(name: "Ohio", abbreviation: "OH", registrationURL: "https://olvr.ohiosos.gov/"),
        StateInfo(name: "Oklahoma", abbreviation: "OK", registrationURL: "https://okvoterportal.okelections.us/"),
        StateInfo(name: "Oregon", abbreviation: "OR", registrationURL: "https://sos.oregon.gov/voting/Pages/registration.aspx"),
        StateInfo(name: "Pennsylvania", abbreviation: "PA", registrationURL: "https://www.pavoterservices.pa.gov/Pages/VoterRegistrationApplication.aspx"),
        StateInfo(name: "Rhode Island", abbreviation: "RI", registrationURL: "https://vote.sos.ri.gov/ovr/"),
        StateInfo(name: "South Carolina", abbreviation: "SC", registrationURL: "https://info.scvotes.sc.gov/eng/ovr/start.aspx"),
        StateInfo(name: "South Dakota", abbreviation: "SD", registrationURL: "https://sdsos.gov/elections-voting/voting/register-to-vote/default.aspx"),
        StateInfo(name: "Tennessee", abbreviation: "TN", registrationURL: "https://ovr.govote.tn.gov/"),
        StateInfo(name: "Texas", abbreviation: "TX", registrationURL: "https://txapps.texas.gov/tolapp/ovr/"),
        StateInfo(name: "Utah", abbreviation: "UT", registrationURL: "https://secure.utah.gov/voterreg/index.html"),
        StateInfo(name: "Vermont", abbreviation: "VT", registrationURL: "https://olvr.vermont.gov/"),
        StateInfo(name: "Virginia", abbreviation: "VA", registrationURL: "https://www.elections.virginia.gov/citizen-portal/"),
        StateInfo(name: "Washington", abbreviation: "WA", registrationURL: "https://www.sos.wa.gov/elections/voters/"),
        StateInfo(name: "West Virginia", abbreviation: "WV", registrationURL: "https://ovr.sos.wv.gov/Register/Landing"),
        StateInfo(name: "Wisconsin", abbreviation: "WI", registrationURL: "https://myvote.wi.gov/en-us/RegisterToVote"),
        StateInfo(name: "Wyoming", abbreviation: "WY", registrationURL: "https://sos.wyo.gov/Elections/State/RegisterToVote.aspx")
    ]
}

struct StateInfoView: View {
    let state: StateInfo

    var body: some View {
        Text(state.name)
            .foregroundColor(.primary)
        Text(state.abbreviation)
            .foregroundColor(.secondary)
    }
}

struct StateInfo_Previews: PreviewProvider {
    static var previews: some View {
        StateInfoView(state: StateInfo(name: "Alabama", abbreviation: "AL", registrationURL: "https://www.alabamavotes.gov/olvr/default.aspx"))
    }
} 