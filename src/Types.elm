module Types exposing (..)

import Kinto
import Set


type alias Model =
    { email : Maybe String
    , password : Maybe String
    , error : Maybe String
    , currentPage : Pages
    , threatForm : ThreatFormData
    , risksPager : Maybe (Kinto.Pager Risk)
    , nextPage : Pages
    , selectedRisk : Maybe Risk
    , riskChanged : Bool
    }


type alias ThreatFormData =
    { threat_objectives_at_stake : Set.Set String
    , threat_project_package : String
    , threat_type : String
    , threat_description : String
    , threat_title : String
    , threat_cause : String
    , threat_impact_schedule : String
    , threat_impact_cost : String
    , threat_impact_performance : String
    , threat_probability : String
    , threat_mitigation : String
    }


emptyThreatForm : ThreatFormData
emptyThreatForm =
    { threat_objectives_at_stake = Set.empty
    , threat_project_package = ""
    , threat_type = ""
    , threat_description = ""
    , threat_title = ""
    , threat_cause = ""
    , threat_impact_schedule = ""
    , threat_impact_cost = ""
    , threat_impact_performance = ""
    , threat_probability = ""
    , threat_mitigation = ""
    }


type Pages
    = LoginPage
    | HomePage
    | ThreatForm
    | OpportunityForm
    | ConfirmationPage
    | DashboardPage


type Msg
    = NewEmail String
    | NewPassword String
    | Login
    | FetchRecordsResponse (Result Kinto.Error (Kinto.Pager Risk))
    | CreateRecordResponse (Result Kinto.Error Risk)
    | GoToConfirmationPage
    | GoToDashboardPage
    | GoToHomePage
    | GoToLoginPage
    | GoToOpportunityForm
    | GoToThreatForm
    | SubmitThreatForm
    | ThreatFieldChange ThreatInput String
    | SelectRisk Risk
    | ClosePopup
    | UpdateComment String
    | UpdateStatus String
    | RiskUpdatedResponse (Result Kinto.Error Risk)



--| DeleteRecord RecordId


type ThreatInput
    = ThreatObjectives
    | ThreatProjectPackage
    | ThreatType
    | ThreatDescription
    | ThreatTitle
    | ThreatCause
    | ThreatImpactSchedule
    | ThreatImpactCost
    | ThreatImpactPerformance
    | ThreatProbability
    | ThreatMitigation


type alias Risk =
    { id : String
    , last_modified : Int
    , title : String
    , admin : RiskAdmin
    , objectives_at_stake : List String
    , project_package : String
    , threat_type : String
    , description : String
    , cause : String
    , impact_schedule : String
    , impact_cost : String
    , impact_performance : String
    , probability : String
    , mitigation : String
    , author_email : String
    }


type alias RiskAdmin =
    { comment : String
    , status : String
    }
